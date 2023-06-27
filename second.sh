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
echo "Setting GTK, Icon, Sound, and Cursor theme..."
xfconf-query -c xsettings -p /Net/ThemeName -s "Juno"
xfconf-query -c xsettings -p /Net/IconThemeName -s "beautyline"
xfconf-query --channel xsettings --property /Gtk/CursorThemeName --set oreo_teal_cursors
xfconf-query -c xsettings -p /Net/EnableEventSounds -s true
xfconf-query -c xsettings -p /Net/EnableInputFeedbackSounds -s true
xfconf-query -c xsettings -p /Net/SoundThemeName -s "Smooth"
xfconf-query -c xfwm4 -p /general/theme -s Juno
xfconf-query -c xfwm4 -p /general/button_layout -s "CMH|O"
echo "Adding some things to autostart..."
cd /home/aneesh/paxxer
mkdir ~/.config
mkdir ~/.config/autostart
cp conky.desktop ~/.config/autostart/
cp startsound.desktop ~/.config/autostart/
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
