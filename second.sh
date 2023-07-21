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
cd ~
echo "echo Welcome to Debian! It is currently $(date)." > ~/.config/fish/config.fish
fish -c "set -U fish_greeting "🐟" "
echo "Installing Binder and Ashmem DKMS modules..."
cd ~
git clone https://github.com/choff/anbox-modules
sudo apt install dkms
cd anbox-modules
sudo cp anbox.conf /etc/modules-load.d/
sudo cp 99-anbox.rules /lib/udev/rules.d/
sudo cp -rT ashmem /usr/src/anbox-ashmem-1
sudo cp -rT binder /usr/src/anbox-binder-1
sudo dkms install anbox-ashmem/1
sudo dkms install anbox-binder/1
sudo update-initramfs -u
sudo modprobe ashmem_linux
sudo modprobe binder_linux
cd ..
rm -rf anbox-modules
cd /home/aneesh/paxxer
echo "Setting up Waydroid..."
sudo apt install curl ca-certificates -y
curl https://repo.waydro.id | sudo bash
sudo apt install waydroid -y
sudo systemctl enable waydroid-container.service
sudo waydroid init
sudo systemctl start waydroid-container.service
sudo waydroid prop set persist.waydroid.multi_windows true
sudo waydroid shell wm set-fix-to-user-rotation enabled
echo "Installing Aurora Store..."
sudo waydroid app install /home/aneesh/paxxer/AuroraStore.apk
echo "Setting up Conky..."
sudo apt install conky
mkdir /home/aneesh/.config
mkdir /home/aneesh/.config/autostart
cp /home/aneesh/paxxer/.conkyrc ~
cp /home/aneesh/paxxer/conky-startup.desktop ~/.config/autostart
echo "Setting up Phosh..."
mkdir ~/.config/gtk-3.0
sudo cp /home/aneesh/paxxer/gtk.css ~/.config/gtk-3.0
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
echo "Installing oh-my-fish"
