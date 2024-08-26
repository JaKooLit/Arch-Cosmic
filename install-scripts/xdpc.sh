#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# XDG-Desktop-Portals #


xdg=(
  xdg-desktop-portal-cosmic
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_xdph.log"

# XDG-DESKTOP-PORTAL-COSMIC
for xdgs in "${xdg[@]}"; do
  install_package "$xdgs" 2>&1 | tee -a "$LOG"
    if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $xdgs Package installation failed, Please check the installation logs"
    exit 1
    fi
done



clear
