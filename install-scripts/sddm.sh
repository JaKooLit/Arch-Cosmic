#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# SDDM Log-in Manager #
if [[ $USE_PRESET = [Yy] ]]; then
  source ./preset.sh
fi

sddm=(
  qt6-5compat 
  qt6-declarative 
  qt6-svg
  sddm
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_sddm.log"


# Install SDDM and SDDM theme
printf "${NOTE} Installing sddm and dependencies........\n"
  for package in "${sddm[@]}"; do
  install_package "$package" 2>&1 | tee -a "$LOG"
  [ $? -ne 0 ] && { echo -e "\e[1A\e[K${ERROR} - $package Package installation failed, Please check the installation logs"; exit 1; }
 done 

# Check if other login managers installed and disabling its service before enabling sddm
for login_manager in lightdm gdm lxdm lxdm-gtk3; do
  if pacman -Qs "$login_manager" > /dev/null; then
    echo "disabling $login_manager..."
    sudo systemctl disable "$login_manager.service" 2>&1 | tee -a "$LOG"
  fi
done

printf " Activating sddm service........\n"
sudo systemctl enable sddm

# Set up SDDM
echo -e "${NOTE} Setting up the login screen."
sddm_conf_dir=/etc/sddm.conf.d
[ ! -d "$sddm_conf_dir" ] && { printf "$CAT - $sddm_conf_dir not found, creating...\n"; sudo mkdir "$sddm_conf_dir" 2>&1 | tee -a "$LOG"; }

wayland_sessions_dir=/usr/share/wayland-sessions
[ ! -d "$wayland_sessions_dir" ] && { printf "$CAT - $wayland_sessions_dir not found, creating...\n"; sudo mkdir "$wayland_sessions_dir" 2>&1 | tee -a "$LOG"; }
sudo cp assets/hyprland.desktop "$wayland_sessions_dir/" 2>&1 | tee -a "$LOG"
    
# SDDM-themes
valid_input=false
while [ "$valid_input" != true ]; do
    if [[ -z $install_sddm_theme ]]; then
      read -n 1 -r -p "${CAT} OPTIONAL - Would you like to install SDDM themes? (y/n)" install_sddm_theme
    fi
  if [[ $install_sddm_theme =~ ^[Yy]$ ]]; then
    printf "\n%s - Installing Simple SDDM Theme\n" "${NOTE}"

    # Check if /usr/share/sddm/themes/simple-sddm-2 exists and remove if it does
    if [ -d "/usr/share/sddm/themes/simple-sddm-2" ]; then
      sudo rm -rf "/usr/share/sddm/themes/simple-sddm-2"
      echo -e "\e[1A\e[K${OK} - Removed existing 'simple-sddm-2' directory." 2>&1 | tee -a "$LOG"
    fi

    # Check if simple-sddm-2 directory exists in the current directory and remove if it does
    if [ -d "simple-sddm-2" ]; then
      rm -rf "simple-sddm-2"
      echo -e "\e[1A\e[K${OK} - Removed existing 'simple-sddm-2' directory from the current location." 2>&1 | tee -a "$LOG"
    fi

    if git clone --depth 1 https://github.com/JaKooLit/simple-sddm-2.git; then
      while [ ! -d "simple-sddm-2" ]; do
        sleep 1
      done

      if [ ! -d "/usr/share/sddm/themes" ]; then
        sudo mkdir -p /usr/share/sddm/themes
        echo -e "\e[1A\e[K${OK} - Directory '/usr/share/sddm/themes' created." 2>&1 | tee -a "$LOG"
      fi

      sudo mv simple-sddm-2 /usr/share/sddm/themes/
      echo -e "[Theme]\nCurrent=simple-sddm-2" | sudo tee "$sddm_conf_dir/theme.conf.user" &>> "$LOG"
    else
      echo -e "\e[1A\e[K${ERROR} - Failed to clone the theme repository. Please check your internet connection" | tee -a "$LOG" >&2
    fi
    valid_input=true
  elif [[ $install_sddm_theme =~ ^[Nn]$ ]]; then
    printf "\n%s - No SDDM themes will be installed.\n" "${NOTE}" 2>&1 | tee -a "$LOG"
    valid_input=true
  else
    printf "\n%s - Invalid input. Please enter 'y' for Yes or 'n' for No.\n" "${ERROR}" 2>&1 | tee -a "$LOG"
    install_sddm_theme=""
  fi
done

clear
