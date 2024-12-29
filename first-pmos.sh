#!/bin/bash

echo "Setting variables..."
PAXXERDIR=$PWD
CUR_HOSTNAME=$(cat /etc/hostname)
KERNEL=$(uname -r)
ARCH=$(uname -m)

echo y | sudo apk add curl bash alpine-conf git
clear
echo ""
echo "Announcements from Paxxer Developers:"
echo ""
curl -s https://raw.githubusercontent.com/aneeshlingala/paxxer/paxxer/announcements | cat
echo ""
echo "Press the spacebar to exit announcements..."
read -r -s -d ' '
echo ""

echo "Running a few checks..."

if [[ $EUID -eq 0 ]]; then
echo "Error: Do not run this script as root!" 1>&2
echo "Solution: Run this script as a normal user without sudo."
exit
fi

if ping -q -c 1 -W 1 google.com >/dev/null; then
  echo "You are online, continuing..."
  echo ""
else
  echo "Error: You are offline."
  echo ""
  echo "Press any key to launch the Network Connection Wizard..."
  read -s -n 1
  echo ""
  echo "Pressed a key, launching the Network Connection Wizard..."
  nmtui
fi

if [[ -f "$PWD/second.sh" ]]; then
    echo "Script is running from the root directory of the repository, continuing..."
else
    echo "Error: Please run this script from the Paxxer repository."
    exit
fi

if [[ -f "/etc/paxxer-successful" ]]; then
    echo "Error: Paxxer was launched before on this system."
    exit
else
    echo "Paxxer has not run before, continuing..."
fi

if [[ "$ARCH" == "x86_64" ]]; then
    echo "Architecture is x64, continuing..."
else
    if [[ "$ARCH" == "aarch64" ]]; then
        echo "Architecture is aarch64, continuing..."
    else
        echo "Error: Paxxer does not work on $(echo $ARCH) architecture."
    fi
fi

echo "PaxxerPmOS, a setup tool to setup my PostmarketOS system, to my liking."
echo "Version: 2024.12.07"

echo "Adding user Aneesh..."
sudo adduser aneesh
sudo mkdir /home/aneesh
sudo usermod -a -G wheel aneesh
echo "Setting root password..."
sudo passwd
sudo usermod -aG netdev aneesh


if [[ "$ARCH" == "aarch64" ]]; then
    echo "Setting Hostname..."
    sudo setup-hostname -n kappa
fi

cd ~
sudo git clone https://github.com/vinceliuice/Graphite-gtk-theme
cd Graphite-gtk-theme
echo y | sudo apk add sassc
sudo bash install.sh -t teal -c dark --tweaks nord 
cd ~
sudo git clone https://github.com/SylEleuth/gruvbox-plus-icon-pack
sudo mkdir /usr/share/icons
sudo mkdir /usr/share/icons/Gruvbox
cd gruvbox-plus-icon-pack
sudo cp -r Gruvbox-Plus-Dark/* /usr/share/icons/Gruvbox/
cd ~
sudo git clone https://github.com/yeyushengfan258/Afterglow-Cursors
cd Afterglow-Cursors
sudo mkdir /usr/share/icons
echo "Copying icons, this may take a while..."
sudo cp -r dist /usr/share/icons/Afterglow-cursors
cd ~
sudo rm -rf Afterglow-Cursors
echo "Setting timezone to America/Los_Angeles"
sudo setup-timezone -z America/Los_Angeles
echo "Upgrading System..."
sudo apk update
echo y | sudo apk upgrade
echo "Cleaning up..."
sudo rm -rf /var/cache/apk/*
echo "Installing Prism Launcher..."
echo y | sudo apk add prismlauncher openjdk17-jdk openjdk21-jdk
echo "Installing KDE Desktop..."
cd ~
echo y | sudo apk add konsole postmarketos-ui-plasma-desktop gwenview ark atril telegram-desktop plasma-systemmonitor cups kcalc fish vlc nano dolphin
echo "Installing KDE Themes..."
cd ~
sudo git clone https://github.com/vinceliuice/Graphite-kde-theme
cd Graphite-kde-theme
sudo bash install.sh
cd ~
echo "Installing LightDM..."
echo y | sudo apk add lightdm --force-overwrite
echo y | sudo apk add lightdm-gtk-greeter
sudo rc-update add lightdm
sudo rc-update del sddm
echo y | sudo apk del maliit-keyboard
echo "Installing Firefox..."
echo y | sudo apk add firefox
echo "Adding Alpine Linux Backgrounds..."
sudo mkdir /usr/share/backgrounds
sudo mkdir /usr/share/backgrounds/bg
sudo cp $PAXXERDIR/bg.jpg /usr/share/backgrounds/bg/
cd ~
echo "LIBGL_ALWAYS_SOFTWARE=true" | sudo tee -a /etc/environment

echo "Setting default shell as fish..."
sudo chsh --shell /usr/bin/fish aneesh
echo "Copying files for second.sh..."
sudo mkdir /home/aneesh/paxxer
sudo cp $PAXXERDIR/second-pmos.sh /home/aneesh/paxxer
sudo chmod +x /home/aneesh/paxxer/second.sh
sudo touch /etc/paxxer-first-done

if [[ "$ARCH" == "x86_64" ]]; then
    echo "Setting Hostname..."
    sudo setup-hostname -n terra
    echo "b43" | sudo tee -a /etc/modules
fi

sudo rm -rf ~/gruvbox-plus-icon-pack ~/Graphite-gtk-theme
echo "After rebooting, run the second-pmos.sh script located in /home/aneesh/paxxer with bash."
echo "NOTE: After rebooting, login as user aneesh, or the script will break."
echo ""
echo "Press any key to reboot..."
read -s -n 1
echo ""
echo "Pressed a key, rebooting..."
sudo reboot
