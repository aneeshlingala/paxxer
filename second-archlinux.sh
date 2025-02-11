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
    echo "Error: Please run first-archlinux.sh, then second-archlinux.sh."
    exit
fi

sudo chown -R aneesh:aneesh /home/aneesh
cd /home/aneesh/paxxer
echo "Deleting user $(cat /etc/paxxer-user)..."
sudo userdel $(cat /etc/paxxer-user)
sudo rm -rf /home/$(cat /etc/paxxer-user)
sudo rm -rf /etc/paxxer-user
echo "Upgrading System..."
sudo pacman -Syu
echo "Cleaning up..."
sudo pacman -S dconf-editor
sudo pacman -Scc
cd ~
echo "echo Welcome to Arch Linux!" > ~/.config/fish/config.fish
fish -c "set -U fish_greeting "🐟" "

if [[ "$ARCH" == "aarch64" ]]; then
   echo "Setting up Conky..."
   sudo pacman -S conky
   mkdir /home/aneesh/.config
   mkdir /home/aneesh/.config/autostart
   cp /home/aneesh/paxxer/.conkyrc ~
   cp /home/aneesh/paxxer/conky-startup.desktop ~/.config/autostart
fi

echo "Theming MATE..."
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
cd ~
sudo touch /etc/paxxer-successful
sudo rm -rf /home/aneesh/paxxer
echo "PLEASE READ below:"
echo "Install harleen theme with omf install harleen, then reboot."
echo "Press any key to install oh-my-fish..."
read -s -n 1
echo ""
echo "Pressed a key, installing oh-my-fish..."
cd ~
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish



