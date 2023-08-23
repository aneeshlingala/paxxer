#!/bin/bash

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

sudo killall light-locker

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

echo "Upgrading to Debian Unstable..."
sudo apt purge unattended-upgrades --autoremove -y
sudo apt install apt-listbugs apt-listchanges ffmpeg -y
sudo rm -rf /etc/apt/sources.list
sudo touch /etc/apt/sources.list
echo "deb http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list
sudo apt update -y
echo "Note: Please check if apt is removing any necessary packages."
sleep 7
sudo apt full-upgrade --autoremove
sudo apt clean
sleep 11
sudo touch /etc/paxxer-successful
echo "PLEASE READ below:"
echo "Install harleen theme with omf install harleen."
echo "Press any key to install oh-my-fish..."
read -s -n 1
echo ""
echo "Pressed a key, installing oh-my-fish..."
cd ~
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
