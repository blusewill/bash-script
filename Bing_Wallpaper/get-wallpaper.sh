#!/bin/bash

SleepTime=0

urlpath=$(
  curl -s "https://www.bing.com/HPImageArchive.aspx?format=rss&idx=0&n=1&mkt=en_US" |
    xmllint --xpath "/rss/channel/item/link/text()" - 2>/dev/null |
    sed 's/1366x768/1920x1080/g'
)

while true; do
  if ping -q -c 1 -W 1 google.com >/dev/null 2>&1; then
    if [ -n "$urlpath" ]; then
      curl -s "https://www.bing.com$urlpath" -o ~/Pictures/BingWallpaper/Daily.png
      feh --bg-fill ~/Pictures/BingWallpaper/Daily.png
      notify-send "Bing Wallpaper" "Wallpaper updated successfully"
    else
      notify-send "Bing Wallpaper" "Failed to fetch image URL"
    fi
    break
  else
    feh --bg-fill ~/Pictures/BingWallpaper/Daily.png

    if ((SleepTime < 600)); then
      SleepTime=$((SleepTime + 60))
      notify-send "Bing Wallpaper Script" "Retrying in $SleepTime seconds"
      sleep "$SleepTime"
    else
      notify-send "Bing Wallpaper Script" "Wallpaper fetching failed after retries"
      break
    fi
  fi
done
