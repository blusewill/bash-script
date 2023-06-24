urlpath=$( \
curl "https://www.bing.com/HPImageArchive.aspx?format=rss&idx=0&n=1&mkt=en_US" \
| xmllint --xpath "/rss/channel/item/link/text()" - \
| sed 's/1366x768/1920x1080/g' \
)

if ping -q -c 1 -W 1 google.com >/dev/null 2>&1; then
    rm -rf ~/Pictures/BingWallpaper/Daily.png
    curl "https://www.bing.com$urlpath" -o ~/Pictures/BingWallpaper/Daily.png
    feh --bg-fill ~/Pictures/BingWallpaper/Daily.png
else
    feh --bg-fill ~/Pictures/BingWallpaper/Daily.png
fi

