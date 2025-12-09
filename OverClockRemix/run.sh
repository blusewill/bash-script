#!/bin/bash

SHOW_W="/tmp/ocremix-download-all-show_w.txt"
if [ -f "$SHOW_W" ]; then
    rm "$SHOW_W"
fi

if [ -z "$FOLDER" ]; then FOLDER="$HOME/Music/OC ReMix Collection/"; fi
if [ -z "$START" ]; then START=4859; fi
if [ -z "$END" ]; then END=4883; fi
if [ -z "$MIRROR" ]; then MIRROR="ocrmirror.org"; fi
if [ -z "$LIMIT" ]; then LIMIT="100m"; fi
if [ -z "$WAIT" ]; then WAIT=0; fi

myConfsDir="$HOME/.config/ocremix-download-all"
mkdir -p "$myConfsDir"
myConf="$myConfsDir/settings.rc"

_FOLDER="$FOLDER"
_START="$START"
_END="$END"
_LIMIT="$LIMIT"
_WAIT="$WAIT"

if [ -f "$myConf" ]; then
    source $myConf
    # ^ Use `source` not `.`, since using a bash shebang.
fi

me=ocremix-download-all.sh

if [ "@$SHOW_BANDWIDTH_WARNING" = "@" ]; then
    SHOW_BANDWIDTH_WARNING=true
fi

if [ ! -f "$myConf" ]; then
    touch "$myConf"
fi

if [ -z "`cat $myConf | grep FOLDER`" ]; then
    echo "FOLDER=\"$FOLDER\"" >> "$myConf"
fi
if [ -z "`cat $myConf | grep START`" ]; then
    echo "START=$START" >> "$myConf"
fi
if [ -z "`cat $myConf | grep END`" ]; then
    echo "END=$END" >> "$myConf"
fi
if [ -z "`cat $myConf | grep MIRROR`" ]; then
    echo "MIRROR=$MIRROR" >> "$myConf"
fi
if [ -z "`cat $myConf | grep LIMIT`" ]; then
    echo "LIMIT=$LIMIT" >> "$myConf"
fi
if [ -z "`cat $myConf | grep WAIT`" ]; then
    echo "WAIT=$WAIT" >> "$myConf"
fi

>&2 echo

>&2 echo "\"$myConf\":"
cat "$myConf" >&2

>&2 echo
_CHANGED=false
if [ "@$_FOLDER" != "@" ]; then
    FOLDER="$_FOLDER"
    >&2 echo "overridden by environment: FOLDER=$FOLDER"
    _CHANGED=true
fi
if [ "@$_START" != "@" ]; then
    START="$_START"
    >&2 echo "overridden by environment: START=$START"
    _CHANGED=true
fi
if [ "@$_END" != "@" ]; then
    END="$_END"
    >&2 echo "overridden by environment: END=$END"
    _CHANGED=true
fi
if [ "@$_MIRROR" != "@" ]; then
    MIRROR="$_MIRROR"
    >&2 echo "overridden by environment: MIRROR=$MIRROR"
    _CHANGED=true
fi
if [ "@$_WAIT" != "@" ]; then
    WAIT="$_WAIT"
    >&2 echo "overridden by environment: WAIT=$WAIT"
    _CHANGED=true
fi

if [ "@$_CHANGED" = "@true" ]; then
    >&2 echo
    printf "* saving the above new settings..." >&2
    echo "FOLDER=\"$FOLDER\"" > "$myConf"
    echo "START=$START" >> "$myConf"
    echo "END=$END" >> "$myConf"
    echo "MIRROR=$MIRROR" >> "$myConf"
    echo "LIMIT=$LIMIT" >> "$myConf"
    echo "WAIT=$WAIT" >> "$myConf"
    echo "SHOW_BANDWIDTH_WARNING=$SHOW_BANDWIDTH_WARNING" >> "$myConf"
    echo "LAST_RUN_DATE=`date '+%Y-%m-%d'`" >> "$myConf"
    if [ $? -ne 0 ]; then
        >&2 echo "FAILED"
    else
        >&2 echo "OK"
    fi
fi
>&2 echo


if [ "@$SHOW_BANDWIDTH_WARNING" = "@true" ]; then
    >&2 echo
    >&2 echo "First download using torrent to avoid slamming the servers:"
    >&2 echo "<https://ocremix.org/torrents>"
    >&2 echo
    >&2 echo "then use this script to only download updated files, otherwise change the START and END environment variables in $myConf (limit the bitrate in bytes as per wget --limit-rate using the LIMIT setting)!"
    sleep 2
    >&2 echo "Press Ctrl C within 5 seconds to cancel..."
    sleep 1
    >&2 echo "4..."
    sleep 1
    >&2 echo "3..."
    sleep 1
    >&2 echo "2..."
    sleep 1
    >&2 echo "1..."
    sleep 1
    echo "SHOW_BANDWIDTH_WARNING=false" >> "$myConf"
fi


cd "$FOLDER"
if [ $? -ne 0 ]; then
    >&2 echo "Error: 'cd \"$FOLDER\"' failed."
    exit 1
fi
echo "# PWD=\"`pwd`\"" | tee -a "$LOG_PATH"
echo "# START=$START" | tee -a "$LOG_PATH"
echo "# END=$END" | tee -a "$LOG_PATH"

>&2 echo

for ((i=$START;i<=$END;i++)); do
    strlen=${#i};
    ERROR=""
    case $strlen in
        "1") file="0000$i"; ;;
        "2") file="000$i";  ;;
        "3") file="00$i";   ;;
        "4") file="0$i";    ;;
        "5") file="$i";     ;;
    esac
    printf "* getting metadata for OCR$file..." >&2
    LOGGABLE_HTML_URL="https://ocremix.org/remix/OCR$file"
    url=$(curl --silent https://ocremix.org/remix/OCR$file | grep $MIRROR | sed 's/<a href=\"\(.*\)\">\(.*\)/\1/');
    url=$(echo $url | sed 's/<[^>]*>/\n/g');
    url=$(echo "$url" | sed 's/&amp;/\&/g'); # replace &amp; with & (See <https://www.unix.com/unix-for-dummies-questions-and-answers/158742-replace.html>)
    # ^ remove additional tags such as <li>

    url="${url#"${url%%[![:space:]]*}"}"
    # ^ remove leading whitespace
    url="${url%"${url##*[![:space:]]}"}"
    # ^ remove trailing whitespace
    # ^ both as per <https://stackoverflow.com/a/3352015/4541104>
    #   (POSIX-compliant)

    if [ -n "$url" ]; then
        # -n: non-zero-length string
        DL_NAME="${url##*/}" # Get the basename from a URL in bash.
        if [ ! -f "$DL_NAME" ]; then
            printf "Retrieving MP3..." >&2
            # >&2 echo "* $DL_NAME doesn't exist in `pwd`."
            wget -O "$DL_NAME" --limit-rate=$LIMIT --continue --no-verbose $url
            # -c: --continue
            # -nv: --no-verbose
            # -nc: --no-clobber
            if [ $? -ne 0 ]; then
                ERROR="FAILED: Downloading $url failed (See <$LOGGABLE_HTML_URL>)."
                echo "# $ERROR" >> "$LOG_PATH"
                >&2 echo "$ERROR"
            else
                >&2 echo "OK"
                echo "# URL:<$url>" >> "$LOG_PATH"
                echo "`pwd`/$DL_NAME" | tee -a "$LOG_PATH"
            fi
            if [ $WAIT -gt 0 ]; then
                >&2 echo "Waiting $WAIT seconds.";
                sleep $WAIT;
            fi
        else
            # There is a slight pause even if the file exists, but that
            # is only due to scraping the page further up (necessary
            # to get the filename).
            # >&2 echo "* INFO: \"`pwd`/$DL_NAME\" already exists"
            >&2 echo "OK"
            echo "# URL:$url"
            echo "`pwd`/$DL_NAME"
        fi
    else
        # ERROR="* Error: URL=\"$url\" (blank) for OCR$file (See <$LOGGABLE_HTML_URL>)";
        ERROR="* INFO: There was no song URL at the page <$LOGGABLE_HTML_URL> (This is only a problem if it happens in all cases)."
        >&2 echo "$ERROR"
    fi
done

>&2 echo "Done $START to $END"
>&2 echo "saved $myConf"
>&2 echo "appended to $LOG_PATH"
>&2 echo "The standard output of this program is an M3U playlist. Examples:"
>&2 echo "  $me > \"(New) $_DATE_STRING OCR$START-$END.m3u\""
>&2 echo "  # (You can run the program again to output the same list without re-downloading, but the filename will still have to be downloaded)"
