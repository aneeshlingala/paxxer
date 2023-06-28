#!/bin/bash

if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run as root" 1>&2
  echo "Solution: Run this script as a normal user without sudo." 1>&2
  exit
fi

echo "Network Connection Wizard - Loading..."
sleep 3
nmtui
sudo chown -R aneesh:aneesh /home/aneesh
cd /home/aneesh/paxxer
echo "Deleting user linux"
sudo userdel linux
sudo rm -rf /home/linux
echo "Upgrading System..."
sudo apt upgrade -y
echo "Theming System..."
gsettings set org.gnome.desktop.interface gtk-theme "Juno"
gsettings set org.gnome.desktop.interface icon-theme "beautyline"
gsettings set org.gnome.desktop.interface cursor-theme "Layan-border-cursors"
gsettings set org.gnome.desktop.wm.preferences button-layout "close,maximize,minimize:"
gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/lights/lights.jpg"
gsettings set org.gnome.desktop.sound event-sounds "true"
gsettings set org.gnome.desktop.sound.input feedback-sounds "true"
gsettings set org.gnome.desktop.sound theme-name "deepin"
echo "echo Welcome to Debian! It is currently $(date)." > ~/.config/fish/config.fish
set -U fish_greeting "🐟"
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean
rm -rf /home/aneesh/paxxer
echo "PLEASE READ below:"
echo "Install boxfish theme with omf install boxfish. After installing boxfish theme, rebooting is required."
echo ""
echo "Press any key to install oh-my-fish..."
read -s -n 1
echo ""
echo "Pressed a key, installing oh-my-fish..."
cd ~
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
echo "Installing oh-my-fish"
