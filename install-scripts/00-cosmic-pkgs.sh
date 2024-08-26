#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# cosmic Packages #

# edit your packages desired here. 
# WARNING! If you remove packages here, dotfiles may not work properly.
# and also, ensure that packages are present in AUR and official Arch Repo

# add packages wanted here
Extra=(

)

cosmic_package=( 
  cosmic-applibrary
  cosmic-applets
  cosmic-bg
  cosmic-comp
  cosmic-icon-theme
  cosmic-files
  cosmic-launcher
  cosmic-notifications
  cosmic-osd
  cosmic-panel
  cosmic-randr
  cosmic-screenshot
  cosmic-session
  cosmic-settings
  cosmic-settings-daemon
  cosmic-terminal
  cosmic-text-editor
  cosmic-wallpapers
  cosmic-workspaces
)

# the following packages maybe omitted
cosmicr_package_2=(
  cosmic-store
)


## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_cosmic-pkgs.log"


# Installation of main components
printf "\n%s - Installing cosmic packages.... \n" "${NOTE}"

for PKG1 in "${cosmic_package[@]}" "${cosmic_package_2[@]}" "${Extra[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done


clear

