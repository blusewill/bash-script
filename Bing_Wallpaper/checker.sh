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
    sudo -v >/dev/null 2>&1 || { echo "Please run the script with sudo." >&2; exit 1; }
  fi
}

# Check if the required commands are already available
if command_exists feh && command_exists ping && command_exists curl; then
  echo "Required commands (feh, ping, curl) are already available."
else
  check_sudo

  # Check which package manager is available
  if command_exists apt-get; then
    echo "Detected: apt package manager"
    install_with_apt feh iputils-ping curl
    add_to_installed_packages "feh" "iputils-ping" "curl"
  elif command_exists pacman; then
    echo "Detected: pacman package manager"
    install_with_pacman feh ping curl
    add_to_installed_packages "feh" "ping" "curl"
  elif command_exists dnf; then
    echo "Detected: dnf package manager"
    install_with_dnf feh ping curl
    add_to_installed_packages "feh" "ping" "curl"
  elif command_exists nix-env; then
    echo "Detected: nix-env package manager"
    install_with_nix_env -iA nixpkgs.feh -iA nixpkgs.iputils -iA nixpkgs.curl
    add_to_installed_packages "feh" "iputils" "curl"
  else
    echo "No supported package manager found."
    exit 1
  fi

  output_installed_packages
fi
