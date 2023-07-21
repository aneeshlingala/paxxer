#!/bin/bash

if [[ $EUID -eq 0 ]]; then
echo "Error: Do not run this script as root!" 1>&2
echo "Solution: Run this script as a normal user without sudo."
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

if [[ "$arch" == "aarch64" ]]; then
    echo "Architecture is aarch64, continuing..."
else
    echo "Error: Please run this on an arm64 system. Instructions are in the readme."
    exit
fi

if [[ -b "$PWD/first.sh" ]]; then
    echo "Script is running from the root directory of the repository, continuing..."
else
    echo "Error: Please run this script from the Paxxer repository."
    exit
fi


echo "Paxxer, a setup tool to setup my Debian system, to my liking."
echo "Version: 2023.07.07"
echo "Setting variables..."
PAXXERDIR=$PWD
CUR_HOSTNAME=$(cat /etc/hostname)
NEW_HOSTNAME=kappa
KERNEL=$(uname -r)

echo "Extending rootfs to max..."
sudo bash /scripts/extend-rootfs.sh
sudo rm -rf /scripts
echo "Fixing permissions, this may take a while..."
sudo find /bin /boot /etc /lib /opt /root /sbin /usr -user linux -exec sudo chmod g-w {} \;
sudo find /bin /boot /etc /lib /opt /root /sbin /usr -user linux -exec sudo chown root:root {} \;
sudo find /bin /boot /etc /lib /opt /root /sbin /usr -user linux -type l -exec sudo chown -h root:root {} \;
sudo chmod g-w /
sudo chown root:root /
echo "Adding user Aneesh..."
sudo adduser aneesh
sudo usermod -a -G sudo aneesh
echo "Setting root password..."
sudo passwd
echo "Setting Hostname..."
sudo hostnamectl set-hostname $NEW_HOSTNAME
sudo hostname $NEW_HOSTNAME
sudo sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
sudo sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hostname
echo "Installing Deepin Sound Theme"
sudo apt update -y
sudo apt install gnome-session-canberra sox deepin-sound-theme -y
echo "Removing Libreoffice, this may take a while..."
sudo apt remove libreoffice* --autoremove -y
echo "Installing Beautyline Icons, Layan Cursors, extra tools, Juno GTK Theme, and replacing the archive manager..."
sudo apt install git wget curl alsa-utils fish w3m fonts-noto-color-emoji xdotool ntpsec budgie-desktop -y
sudo apt purge firefox-esr vim vim-tiny plymouth --autoremove -y
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
sudo git clone https://gitlab.com/garuda-linux/themes-and-settings/artwork/beautyline
sudo tar -xvf $PAXXERDIR/cursors.tar.xz -C .
cd ..
echo "Setting timezone to Pacific/Los Angeles"
sudo rm -rf /etc/timezone
touch /etc/timezone
sudo timedatectl set-timezone America/Los_Angeles
echo "Replacing Xfce Desktop with Budgie Desktop"
sudo apt-get purge xfconf xfce4-utils xfwm4 xfce4-session xfdesktop4 exo-utils xfce4-panel xfce4-terminal gnome-system-tools thunar libxfce4ui* *xfce* --autoremove -y
sudo apt install totem eog mousepad file-roller atril nemo gnome-disk-utility gnome-system-monitor tilix -y
sudo apt remove xterm exfalso synaptic lightdm-settings --autoremove -y
sudo apt remove gimp --autoremove -y
echo "Installing LightDM and setting it up..."
sudo apt install ukui-greeter -y
sudo rm -rf /etc/lightdm/lightdm.conf
sudo touch /etc/lightdm/lightdm.conf
echo "[SeatDefaults]" | sudo tee -a /etc/lightdm/lightdm.conf
echo "greeter-session=ukui-greeter" | sudo tee -a /etc/lightdm/lightdm.conf
echo "Installing Wallpaper..."
sudo mkdir /usr/share/backgrounds/lights
sudo cp $PAXXERDIR/lights.jpg /usr/share/backgrounds/lights/
cd ~
echo "Setting default shell as fish..."
sudo chsh --shell /usr/bin/fish aneesh

if [ "$KERNEL" = "5.19.1-stb-mt8+" ]
then
    echo "Updating Kernel..."
    sudo rm -rf /boot/*
    sudo rm -rf /lib/modules/*
    cd ~
    sudo wget "https://github.com/hexdump0815/linux-mainline-mediatek-mt81xx-kernel/releases/download/6.1.11-stb-mt8%2B/6.1.11-stb-mt8+.tar.gz"
    sudo tar -xzvf 6.1.11-stb-mt8+.tar.gz -C / 
    sudo rm -rf 6.1.11-stb-mt8+.tar.gz
    read -p "Enter the disk node (e.g., sda, sdb, etc.): " disk_node

    if [[ $disk_node =~ mmcblk[01] ]]; then
        echo "Running different command for $disk_node..."
        sudo dd if=/boot/vmlinux.kpart-6.1.11-stb-mt8+ of=/dev/${disk_node}p1
        sudo dd if=/boot/vmlinux.kpart-6.1.11-stb-mt8+ of=/dev/${disk_node}p2
        sudo update-initramfs -u

    elif [[ -b $disk_node ]]; then
        sudo dd if=/boot/vmlinux.kpart-6.1.11-stb-mt8+ of=/dev/${disk_node}1
        sudo dd if=/boot/vmlinux.kpart-6.1.11-stb-mt8+ of=/dev/${disk_node}2
        sudo update-initramfs -u
    else
        echo "Invalid disk node. Please enter a valid disk node."
        exit
    fi
fi

sudo mkdir /home/aneesh/paxxer
sudo cp $PAXXERDIR/second.sh /home/aneesh/paxxer
sudo cp $PAXXERDIR/AuroraStore.apk /home/aneesh/paxxer
sudo chmod +x /home/aneesh/paxxer/second.sh
echo "After rebooting, run the second.sh script in /home/aneesh/paxxer."
echo "NOTE: After rebooting, login as user aneesh, or the script will break."
echo ""
echo "Press any key to reboot..."
read -s -n 1
echo ""
echo "Pressed a key, rebooting..."
systemctl reboot
