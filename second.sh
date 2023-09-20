#!/bin/bash

ARCH=$(uname -m)

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" 1>&2
  echo "Solution: Run this script as a normal user without sudo." 1>&2
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

if [ "$(whoami)" != "aneesh" ]; then
        echo "Error: Please reboot and run the script as user aneesh."
        echo "Not rebooting but instead logging out and logging in as aneesh will cause the script to break."
        echo "Rebooting in 5 seconds..."
        sleep 5
        systemctl reboot
        exit
fi

if [[ -f "/etc/paxxer-first-done" ]]; then
    echo "First.sh has been run, good."
    sudo rm -rf /etc/paxxer-first-done
else
    echo "Error: Please run first.sh, then second.sh."
    exit
fi

sudo chown -R aneesh:aneesh /home/aneesh
cd /home/aneesh/paxxer

if [[ "$ARCH" == "x86_64" ]]; then
    echo "Deleting user $(cat /etc/paxxer-user)..."
    sudo userdel $(cat /etc/paxxer-user)
    sudo rm -rf /home/$(cat /etc/paxxer-user)
    sudo rm -rf /etc/paxxer-user
fi

if [[ "$ARCH" == "aarch64" ]]; then
    echo "Deleting user linux..."
    sudo userdel linux
    sudo rm -rf /home/linux
fi

echo "Upgrading System..."
sudo apt upgrade --autoremove -y
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean
sudo apt remove onboard --autoremove -y
sudo apt install gsettings-desktop-schemas libglib2.0-bin dconf-editor -y
cd ~
echo "echo Welcome to Debian!" > ~/.config/fish/config.fish
fish -c "set -U fish_greeting "🐟" "

if [[ "$ARCH" == "aarch64" ]]; then
   echo "Setting up Conky..."
   sudo apt install conky -y
   mkdir /home/aneesh/.config
   mkdir /home/aneesh/.config/autostart
   cp /home/aneesh/paxxer/.conkyrc ~
   cp /home/aneesh/paxxer/conky-startup.desktop ~/.config/autostart
fi

echo "Theming GNOME..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
rm -rf ~/.config/gtk-4.0/gtk.css
rm -rf ~/.config/gtk-4.0/gtk-dark.css
rm -rf ~/.config/gtk-4.0/assets
rm -rf ~/.config/assets
mkdir ~/.config/gtk-4.0
ln -s /usr/share/themes/Juno/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
ln -s /usr/share/themes/Juno/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk-dark.css
ln -s /usr/share/themes/Juno/gtk-4.0/assets ~/.config/gtk-4.0/assets
ln -s /usr/share/themes/Juno/assets ~/.config/assets
echo "GTK_THEME=Juno" | sudo tee -a /etc/environment
gsettings set org.gnome.desktop.interface gtk-theme "Juno"
gsettings set org.gnome.desktop.interface gtk-theme "Juno"
gsettings set org.gnome.desktop.interface icon-theme "kora"
gsettings set org.gnome.desktop.sound theme-name "deepin"
cd ~
echo "Installing Waydroid..."
sudo modprobe binder
sudo touch /etc/modules-load.d/binder.conf
echo "binder" | sudo tee -a /etc/modules-load.d/binder.conf
sudo apt install curl ca-certificates -y
curl https://repo.waydro.id | sudo bash
sudo apt install waydroid -y
sudo systemctl enable waydroid-container
sudo systemctl start waydroid-container
sudo waydroid init
sudo systemctl restart waydroid-container
sudo wget https://auroraoss.com/AuroraStore/Stable/AuroraStore_4.3.2.apk
waydroid app install AuroraStore_4.3.2.apk
waydroid prop set persist.waydroid.multi_windows true
sudo touch /etc/paxxer-second
sudo rm -rf /home/aneesh/paxxer
sudo mkdir /home/aneesh/paxxer
cd /home/aneesh/paxxer
uname -r | sudo tee -a /etc/paxxer-kernel
sudo wget https://raw.githubusercontent.com/aneeshlingala/paxxer/paxxer/third.sh
sudo chmod +x third.sh
cd ~
echo "After rebooting, run third.sh in /home/aneesh/paxxer"
sleep 10
systemctl reboot


