#!/bin/bash

if [[ $EUID -eq 0 ]]; then
echo "Error: Do not run this script as root!" 1>&2
echo "Solution: Run this script as a normal user without sudo."
exit
fi

echo "Paxxer, a setup tool to setup my Debian system, to my liking."
echo "Version: 2023.06.19"
echo "Setting variables..."
PAXXERDIR=$PWD
CUR_HOSTNAME=$(cat /etc/hostname)
NEW_HOSTNAME=kappa
echo "Extending rootfs to max..."
sudo bash /scripts/extend-rootfs.sh
sudo rm -rf /scripts
echo "Adding user Aneesh..."
sudo adduser aneesh
sudo usermod -a -G sudo aneesh
echo "Setting Hostname..."
hostnamectl set-hostname $NEW_HOSTNAME
hostname $NEW_HOSTNAME
sudo sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
sudo sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hostname
echo "Installing Smooth Sound Theme"
sudo apt install gnome-session-canberra sox -y
sudo cp -r $PAXXERDIR/Smooth /usr/share/sounds
echo "Removing Libreoffice, this may take a while..."
sudo apt remove libreoffice* --autoremove -y
echo "Setting up Conky..."
sudo cp $PAXXERDIR/conkyrc /home/aneesh/.conkyrc
echo "Setting up startup sound..."
sudo cp start.wav /usr/share/sounds
echo "Installing Beautyline Icons, Oreo Cursors, extra tools, Juno GTK Theme, and replacing the archive manager..."
sudo apt update -y
sudo apt install git wget curl alsa-utils fish engrampa w3m fonts-noto-color-emoji mugshot conky xdotool ntpsec -y
sudo apt purge firefox-esr vim vim-tiny --autoremove -y
sudo apt remove xarchiver --autoremove -y
echo "Installing Brave Browser..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update -y
sudo apt install brave-browser -y
cd ~
cd /usr/share/themes
sudo git clone https://github.com/eliverlara/Juno
cd /usr/share/icons
git clone https://gitlab.com/garuda-linux/themes-and-settings/artwork/beautyline
sudo tar -xzvf $PAXXERDIR/cursors.tar.gz -C .
cd ..
echo "Setting timezone to Pacific/Los Angeles"
sudo timedatectl set-timezone America/Los_Angeles
echo "Installing SDDM and setting it up..."
sudo apt install sddm -y
sudo touch /etc/sddm.conf
echo "[Theme]" | sudo tee -a /etc/sddm.conf
echo "Current=chili" | sudo tee -a /etc/sddm.conf
echo "CursorTheme=oreo_teal_cursors" | sudo tee -a /etc/sddm.conf
cd /usr/share/sddm/themes
sudo git clone https://github.com/MarianArlt/sddm-chili chili 
cd chili
sudo rm -rf theme.conf
sudo cp $PAXXERDIR/theme.conf theme.conf
sudo apt install qml-module-qtquick-controls qml-module-qtgraphicaleffects -y
echo "Installing Wallpaper..."
sudo mkdir /usr/share/backgrounds/mountains
sudo cp $PAXXERDIR/background.jpg /usr/share/backgrounds/mountains
cd ~
echo "Setting default shell as fish..."
sudo chsh --shell /usr/bin/fish aneesh
echo "Updating Kernel..."
sudo rm -rf /boot/*
sudo rm -rf /lib/modules/*
cd ~
sudo wget "https://github.com/hexdump0815/linux-mainline-mediatek-mt81xx-kernel/releases/download/6.1.11-stb-mt8%2B/6.1.11-stb-mt8+.tar.gz"
sudo tar -xzvf 6.1.11-stb-mt8+.tar.gz -C / 
sudo rm -rf 6.1.11-stb-mt8+.tar.gz
sudo dd if=/boot/vmlinux.kpart-6.1.11-stb-mt8+ of=/dev/mmcblk0p1
sudo dd if=/boot/vmlinux.kpart-6.1.11-stb-mt8+ of=/dev/mmcblk0p2
sudo update-initramfs -u
sudo mkdir /home/aneesh/paxxer
sudo cp $PAXXERDIR/second.sh /home/aneesh/paxxer
sudo chmod +x /home/aneesh/paxxer/second.sh
sudo cp $PAXXERDIR/conky.desktop /home/aneesh/paxxer
sudo cp $PAXXERDIR/startsound.desktop /home/aneesh/paxxer
echo "After rebooting, run the second.sh script in /home/aneesh/paxxer."
echo "NOTE: After rebooting, login as user aneesh, or the script will break."
sleep 5
systemctl reboot
