#!/bin/bash

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

sudo chown -R aneesh:aneesh /home/aneesh
cd /home/aneesh/paxxer
echo "Deleting user linux..."
sudo userdel linux
sudo rm -rf /home/linux
echo "Upgrading System..."
sudo apt upgrade -y
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean
sudo rm -rf /home/aneesh/paxxer
cd ~
echo "echo Welcome to Debian! It is currently $(date)." > ~/.config/fish/config.fish
fish -c "set -U fish_greeting "🐟" "
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
