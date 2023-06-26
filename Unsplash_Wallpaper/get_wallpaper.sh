# Check the Internet is Available or not
if ping -q -c 1 -W 1 google.com >/dev/null 2>&1; then
    rm -rf ~/Pictures/UnsplashWallpaper/Daily.png
    wget -O ~/Pictures/UnsplashWallpaper/Daily.png https://unsplash.it/1920/1080/?random 
    feh --bg-fill ~/Pictures/UnsplashWallpaper/Daily.png
else
    feh --bg-fill ~/Pictures/UnsplashWallpaper/Daily.png
fi
