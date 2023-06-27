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
echo "Cleaning up..."
cd ~
rm -rf /home/aneesh/paxxer
echo "Deleting user linux"
sudo userdel linux
sudo rm -rf /home/linux
echo "Updating System..."
sudo apt upgrade -y
echo "PLEASE READ below:"
echo "Install boxfish theme with omf install boxfish. After installing boxfish theme, rebooting is required."
echo ""
echo "Press any key to install oh-my-fish..."
read -s -n 1
echo ""
echo "Pressed a key, installing oh-my-fish..."
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
echo "Installing oh-my-fish"
