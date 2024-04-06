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

echo "Deleting user linux..."
sudo userdel linux
sudo rm -rf /home/linux


echo "Upgrading System..."
sudo apt upgrade --autoremove -y
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean
sudo apt install gsettings-desktop-schemas libglib2.0-bin dconf-editor -y
echo "Setting up greeting for fish..."
cd ~
echo "echo Welcome to Debian!" > ~/.config/fish/config.fish
fish -c "set -U fish_greeting "🐟" "
echo "Theming MATE..."
rm -rf ~/.config/gtk-4.0/gtk.css
rm -rf ~/.config/gtk-4.0/gtk-dark.css
rm -rf ~/.config/gtk-4.0/assets
rm -rf ~/.config/assets
mkdir ~/.config/gtk-4.0
ln -s /usr/share/themes/Graphite-teal-Dark-nord/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
ln -s /usr/share/themes/Graphite-teal-Dark-nord/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk-dark.css
ln -s /usr/share/themes/Graphite-teal-Dark-nord/gtk-4.0/assets ~/.config/gtk-4.0/assets
ln -s /usr/share/themes/Graphite-teal-Dark-nord/assets ~/.config/assets
echo "GTK_THEME=Graphite-teal-Dark-nord" | sudo tee -a /etc/environment
sudo cp -r /usr/share/themes/Graphite-teal-Dark-nord ~/.themes/
sudo flatpak override --filesystem=$HOME/.themes
sudo flatpak override --env=GTK_THEME=Graphite-teal-Dark-nord
cd ~
sudo touch /etc/paxxer-second
sudo rm -rf /home/aneesh/paxxer
sudo mkdir /home/aneesh/paxxer
cd /home/aneesh/paxxer
uname -r | sudo tee -a /etc/paxxer-kernel
sudo wget https://raw.githubusercontent.com/aneeshlingala/paxxer/paxxer/third-rpi.sh
sudo chmod +x third-rpi.sh
cd ~
echo "After rebooting, run third-rpi.sh in /home/aneesh/paxxer"
echo "Rebooting in ten seconds, press CTRL+C to cancel..."
sleep 10
systemctl reboot
