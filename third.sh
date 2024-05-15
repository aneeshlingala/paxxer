#!/bin/bash

ARCH=$(uname -m)

if [ "$(whoami)" != "aneesh" ]; then
        echo "Error: Please reboot and run the script as user aneesh."
        echo "Not rebooting but instead logging out and logging in as aneesh will cause the script to break."
        exit
fi

if [[ -f "/etc/paxxer-second" ]]; then
    echo "Second.sh has been run, good."
    sudo rm -rf /etc/paxxer-second
else
    echo "Error: Please run second.sh, then third.sh."
    exit
fi

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

if [[ "$ARCH" == "x86_64" ]]; then
   echo "Setting up cpupower..."
   sudo apt install linux-cpupower
   echo "cpupower frequency-set -d 2.48Ghz -u 2.48Ghz -g performance" | sudo tee -a /etc/rc.local  
fi

if [[ "$ARCH" == "aarch64" ]]; then
   sudo rm -rf ~/GitHub
   echo "Setting up Conky..."
   sudo apt install conky-all -y
   cd /home/aneesh/paxxer
   cp -r .conkyrc ~
   mkdir ~/.config
   mkdir ~/.config/autostart
   cp -r conky-startup.desktop ~/.config/autostart/
fi

sleep 11
sudo touch /etc/paxxer-successful
cd ~
sudo rm -rf /home/aneesh/paxxer
echo "PLEASE READ below:"
echo "Install harleen oh-my-fish theme after installation with omf install harleen."
echo "Then, reboot the computer with the command systemctl reboot."
echo "Press any key to install oh-my-fish..."
read -s -n 1
echo ""
echo "Pressed a key, installing oh-my-fish..."
cd ~
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
