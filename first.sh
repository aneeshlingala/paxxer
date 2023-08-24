#!/bin/bash

echo "Setting variables..."
PAXXERDIR=$PWD
CUR_HOSTNAME=$(cat /etc/hostname)
NEW_HOSTNAME=kappa
KERNEL=$(uname -r)
ARCH=$(uname -m)

echo "Running a few checks..."

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

if [[ -f "$PWD/second.sh" ]]; then
    echo "Script is running from the root directory of the repository, continuing..."
else
    echo "Error: Please run this script from the Paxxer repository."
    exit
fi

if [[ -f "/etc/paxxer-successful" ]]; then
    echo "Error: Paxxer was launched before on this system."
    exit
else
    echo "Paxxer has not run before, continuing..."
fi

if [[ "$ARCH" == "aarch64" ]]; then
    echo "Architecture is aarch64, continuing..."
else
    echo "Error: Please run this on an arm64 system."
    exit
fi

echo "Paxxer, a setup tool to setup my Debian system, to my liking."
echo "Version: 2023.08.23"

echo "Extending rootfs to max and increasing swapfile..."
sudo bash /scripts/extend-rootfs.sh
sudo bash /scripts/recreate-swapfile.sh 2G
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
echo "Installing BeautySolar Icon Theme, Afterglow Cursors, extra tools, and Juno GTK Theme"
sudo apt install git wget curl sassc alsa-utils fish w3m fonts-noto-color-emoji xdotool ntpsec rhythmbox -y
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
sudo tar -xf $PAXXERDIR/BeautySolar.tar.gz
sudo git clone https://github.com/yeyushengfan258/Afterglow-Cursors
cd Afterglow-Cursors
sudo bash install.sh
cd ~
sudo rm -rf Afterglow-Cursors
echo "Setting timezone to America/Los Angeles"
sudo rm -rf /etc/timezone
touch /etc/timezone
sudo timedatectl set-timezone America/Los_Angeles
echo "Replacing Xfce Desktop with MATE"
sudo apt install totem eog mousepad file-roller atril gnome-disk-utility gnome-system-monitor mate-applets system-config-printer cups mate-desktop-environment-core telegram-desktop network-manager-gnome mate-calc mate-applet-brisk-menu mate-tweak --no-install-recommends -y
sudo apt-get purge xfconf xfce4-utils xfwm4 xfce4-session xfdesktop4 exo-utils xfce4-panel xfce4-terminal gnome-system-tools thunar libxfce4ui* *xfce* --autoremove -y
sudo apt remove xterm exfalso synaptic lightdm-settings imagemagick --autoremove -y
echo "Installing LXDM and setting it up..."
sudo apt install lxdm --no-install-recommends -y
sudo systemctl disable lightdm.service
sudo systemctl enable lxdm.service
sudo mkdir /usr/share/backgrounds
sudo mkdir /usr/share/backgrounds/debian-lights
sudo cp $PAXXERDIR/lights.png /usr/share/backgrounds/debian-lights/
sudo ln -s /usr/share/wallpapers/SpaceFun/contents/images/1920x1080.svg /etc/lightdm/space.svg
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
sudo cp $PAXXERDIR/.conkyrc /home/aneesh/paxxer
sudo cp $PAXXERDIR/conky-startup.desktop /home/aneesh/paxxer
sudo chmod +x /home/aneesh/paxxer/second.sh
sudo touch /etc/paxxer-first-done
echo "After rebooting, run the second.sh script in /home/aneesh/paxxer."
echo "NOTE: After rebooting, login as user aneesh, or the script will break."
echo ""
echo "Press any key to reboot..."
read -s -n 1
echo ""
echo "Pressed a key, rebooting..."
systemctl reboot
