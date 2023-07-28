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

if [[ -f "/etc/paxxer-first-done" ]]; then
    echo "First.sh has been run, good."
    sudo rm -rf /etc/paxxer-first-done
else
    echo "Error: Please run first.sh, then second.sh."
    exit
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
sudo apt remove onboard --autoremove -y
sudo apt install gsettings-desktop-schemas libglib2.0-bin dconf-editor -y
cd ~
echo "echo Welcome to Debian! It is currently $(date)." > ~/.config/fish/config.fish
fish -c "set -U fish_greeting "🐟" "
echo "Setting up Conky..."
sudo apt install conky
mkdir /home/aneesh/.config
mkdir /home/aneesh/.config/autostart
cp /home/aneesh/paxxer/.conkyrc ~
cp /home/aneesh/paxxer/conky-startup.desktop ~/.config/autostart
echo "Theming Cinnamon..."
rm -rf ~/.config/gtk-4.0
ln -s /usr/share/themes/Juno/gtk-4.0 ~/.config/gtk-4.0
echo "Installing Pi-Apps..."
wget -qO- https://raw.githubusercontent.com/Botspot/pi-apps/master/install | bash
sudo rm -rf /home/aneesh/paxxer
cd ~
sudo touch /etc/paxxer-successful
echo "PLEASE READ below:"
echo "Install harleen theme with omf install harleen. After installing harleen fish theme, rebooting is required."
echo ""
echo "Press any key to install oh-my-fish..."
read -s -n 1
echo ""
echo "Pressed a key, installing oh-my-fish..."
cd ~
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
