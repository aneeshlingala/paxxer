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
        sudo reboot
        exit
fi

if [[ -f "/etc/paxxer-first-done" ]]; then
    echo "First-pmos.sh has been run, good."
    sudo rm -rf /etc/paxxer-first-done
else
    echo "Error: Please run first-pmos.sh, then second-pmos.sh."
    exit
fi

sudo chown -R aneesh:aneesh /home/aneesh
cd /home/aneesh/paxxer

echo "Deleting user linux..."
sudo userdel linux
sudo rm -rf /home/linux
echo "Setting up greeting for fish..."
cd ~
echo "echo Welcome to PostmarketOS!" > ~/.config/fish/config.fish
fish -c "set -U fish_greeting "🐟" "
echo "Adding Minecraft Pi Mods..."
sudo mkdir /home/aneesh/.minecraft-pi/
sudo mkdir /home/aneesh/.minecraft-pi/mods
sudo chown -R aneesh:aneesh /home/aneesh/.minecraft-pi
cd /home/aneesh/.minecraft-pi/mods
echo y | sudo apk add wget
wget "https://cdn.discordapp.com/attachments/740287938453045401/1078558046613143562/libcake.so"
wget "https://github.com/Bigjango13/MCPI-Mods/releases/download/v1.0.2/libexpanded-creative.so"
wget "https://cdn.discordapp.com/attachments/889201475362893844/1003050259712331796/libNoReactorMessage.so"
wget "https://cdn.discordapp.com/attachments/1034896064240689192/1053892162284163273/libspawnEgg.so"
wget "https://github.com/NikZapp/mcpi-block-shenanigans/releases/download/v1.0/libmcpiblocks.so"
wget "https://github.com/NikZapp/mcpi-better-grass-mod/releases/download/v1.0/libniksbettergrass.so"
echo "Setting up Flatpak and installing GTKCord4 (Discord Client for Linux, supporting ARM64, built on GTK4), VSCode LibreWolf Browser, and Minecraft Pi..."
echo y | sudo apk add flatpak pam-rundir linux-pam
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user flathub so.libdb.gtkcord4 -y
flatpak install --user flathub com.thebrokenrail.MCPIReborn -y
flatpak install --user flathub io.gitlab.librewolf-community -y
flatpak install --user flathub com.visualstudio.code -y
flatpak install --user flathub org.prismlauncher.PrismLauncher -y
sudo mkdir /home/aneesh/VSCode
sudo chown aneesh:aneesh /home/aneesh/VSCode
echo "Theming GTK-4 and Flatpak Apps..."
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
lookandfeeltool -a Graphite-nord-dark
cd ~
cd /home/aneesh/paxxer
uname -r | sudo tee -a /etc/paxxer-kernel
echo "Downloading extra needed files..."
sudo wget https://raw.githubusercontent.com/aneeshlingala/paxxer/paxxer/.conkyrc
sudo wget https://raw.githubusercontent.com/aneeshlingala/paxxer/paxxer/conky-startup.desktop
cd ~

if [[ "$ARCH" == "aarch64" ]]; then
   echo "Setting up Conky..."
   echo y | sudo apk add conky
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
