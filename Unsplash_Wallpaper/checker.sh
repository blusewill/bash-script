#!/bin/bash

# Function to check if a command is available
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install packages using apt package manager
install_with_apt() {
  sudo apt-get update
  sudo apt-get install -y "$@"
}

# Function to install packages using pacman package manager
install_with_pacman() {
  sudo pacman -Syu --noconfirm "$@"
}

# Function to install packages using dnf package manager
install_with_dnf() {
  sudo dnf install -y "$@"
}

# Function to install packages using nix-env package manager
install_with_nix_env() {
  nix-env -iA "$@"
}

# Function to create the ~/Pictures/BingWallpaper directory
create_unsplash_wallpaper_directory() {
  mkdir -p ~/Pictures/UnsplashWallpaper
  echo "Created directory: ~/Pictures/UnsplashWallpaper"
}

# Function to check if the ~/Pictures/BingWallpaper directory exists
unsplash_wallpaper_directory_exists() {
  [ -d ~/Pictures/UnsplashWallpaper ]
}

# Array to store installed package names
installed_packages=()

# Function to add package to the installed_packages array
add_to_installed_packages() {
  installed_packages+=("$1")
}

# Function to output the installed package names
output_installed_packages() {
  clear
  echo "Installed packages:"
  for package in "${installed_packages[@]}"; do
    echo "- $package"
  done
}

# Check if running with sudo privileges, if not, ask for sudo
check_sudo() {
  if [[ $EUID -ne 0 ]]; then
    sudo -v >/dev/null 2>&1 || { echo "Please enter your password to continue..." >&2; sudo -v; }
  fi
}

# Check if the required commands are already available
if command_exists feh && command_exists ping && command_exists wget; then
  echo "Required commands (feh, ping, wget) are already available."
else
  check_sudo

  # Check which package manager is available
  if command_exists apt-get; then
    echo "Detected: apt package manager"
    install_with_apt feh iputils-ping curl
    add_to_installed_packages "feh" "iputils-ping" "wget"
  elif command_exists pacman; then
    echo "Detected: pacman package manager"
    install_with_pacman feh ping curl
    add_to_installed_packages "feh" "ping" "wget"
  elif command_exists dnf; then
    echo "Detected: dnf package manager"
    install_with_dnf feh ping curl
    add_to_installed_packages "feh" "ping" "wget"
  elif command_exists nix-env; then
    echo "Detected: nix-env package manager"
    install_with_nix_env -iA nixpkgs.feh -iA nixpkgs.iputils -iA nixpkgs.wget
    add_to_installed_packages "feh" "iputils" "wget"
  else
    echo "No supported package manager found."
    exit 1
  fi

  output_installed_packages
fi

# Check if the ~/Pictures/BingWallpaper directory exists, if not, create it
if unsplash_wallpaper_directory_exists; then
  echo "Directory ~/Pictures/UnsplashWallpaper already exists."
else
  create_unsplash_wallpaper_directory
fi
