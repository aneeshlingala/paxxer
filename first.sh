#!/bin/bash

echo "Setting variables..."
PAXXERDIR=$PWD
CUR_HOSTNAME=$(cat /etc/hostname)
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

if [[ "$ARCH" == "x86_64" ]]; then
    echo "Architecture is x64, continuing..."
else
    if [[ "$ARCH" == "aarch64" ]]; then
        echo "Architecture is aarch64, continuing..."
    else
        echo "Error: Paxxer does not work on $(echo $ARCH) architecture."
    fi
fi

if [ "$KERNEL" = "5.19.1-stb-mt8+" ]
then
    echo "Please run Paxxer on Debian Bookworm."
    echo "Debian Bullseye or older is not supported anymore."
    exit
fi

echo "PaxxerDeb, a setup tool to setup my Debian system, to my liking."
echo "Version: 2023.09.24"

if [[ "$ARCH" == "aarch64" ]]; then
    echo "Extending rootfs to max and increasing swapfile..."
    sudo bash /scripts/extend-rootfs.sh
    sudo bash /scripts/recreate-swapfile.sh 2G
    sudo rm -rf /scripts
fi

if [[ "$USER" == "linux" ]]; then
    echo "Fixing Permissions..."
    sudo find /bin /boot /etc /lib /opt /root /sbin /usr -user linux -exec sudo chmod g-w {} \;
    sudo find /bin /boot /etc /lib /opt /root /sbin /usr -user linux -exec sudo chown root:root {} \;
    sudo find /bin /boot /etc /lib /opt /root /sbin /usr -user linux -type l -exec sudo chown -h root:root {} \;
    sudo chmod g-w /
    sudo chown root:root /
fi

echo "Adding user Aneesh..."
sudo adduser aneesh
sudo usermod -a -G sudo aneesh
echo "Setting root password..."
sudo passwd

if [[ "$ARCH" == "aarch64" ]]; then
    echo "Setting Hostname..."
    sudo hostnamectl set-hostname kappa
    sudo hostname kappa
    sudo sed -i "s/$CUR_HOSTNAME/kappa/g" /etc/hosts
    sudo sed -i "s/$CUR_HOSTNAME/kappa/g" /etc/hostname
    echo "Updating kernel from $(echo $KERNEL) to 6.1.51-stb-mt8+"
    sudo rm -rf /boot/*
    sudo rm -rf /lib/modules/*
    cd ~
    sudo wget "https://github.com/hexdump0815/linux-mainline-mediatek-mt81xx-kernel/releases/download/6.1.51-stb-mt8%2B/6.1.51-stb-mt8+.tar.gz"
    cd /
    sudo tar -xzvf ~/6.1.51-stb-mt8+.tar.gz
    sudo rm -rf 6.1.51-stb-mt8+.tar.gz
    sudo dd if=/boot/vmlinux.kpart-6.1.51-stb-mt8+ of=/dev/mmcblk0p1 bs=1M status=progress
    sudo dd if=/boot/vmlinux.kpart-6.1.51-stb-mt8+ of=/dev/mmcblk0p2 bs=1M status=progress
fi

echo "Installing Deepin Sound Theme"
sudo apt update -y
sudo apt install gnome-session-canberra sox deepin-sound-theme -y
echo "Removing Libreoffice, this may take a while..."
sudo apt remove libreoffice* --autoremove -y
sudo apt purge gimp xterm hv3 --autoremove -y
echo "Installing Kora Icon Theme, Afterglow Cursors, extra tools, and Juno GTK Theme"
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
cd ~
sudo git clone https://github.com/bikass/kora
cd kora
sudo cp -r kora-* /usr/share/icons
sudo cp -r kora /usr/share/icons
cd ..
sudo rm -rf kora
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
sudo apt install totem eog mousepad file-roller atril gnome-disk-utility mate-media-common mate-media mate-power-manager gnome-system-monitor mate-applets system-config-printer cups mate-desktop-environment-core telegram-desktop network-manager-gnome mate-calc mate-applet-brisk-menu mate-tweak --no-install-recommends -y
sudo apt-get purge xfconf xfce4-utils xfwm4 xfce4-session xfdesktop4 exo-utils xfce4-panel xfce4-terminal gnome-system-tools thunar libxfce4ui* *xfce* --autoremove -y
su -c "apt install sudo -y"
sudo apt remove xterm exfalso synaptic lightdm-settings imagemagick --autoremove -y
echo "Installing LightDM and setting it up..."
sudo apt install ukui-greeter lightdm -y
sudo rm -rf /etc/lightdm/lightdm.conf
sudo touch /etc/lightdm/lightdm.conf
echo "[SeatDefaults]" | sudo tee -a /etc/lightdm/lightdm.conf
echo "greeter-session=ukui-greeter" | sudo tee -a /etc/lightdm/lightdm.conf
sudo systemctl enable lightdm
sudo mkdir /usr/share/backgrounds
sudo mkdir /usr/share/backgrounds/debian-lights
sudo cp $PAXXERDIR/lights.png /usr/share/backgrounds/debian-lights/
cd ~
sudo apt purge mlterm mlterm-tiny xiterm+thai --autoremove

if [[ "$ARCH" == "x86_64" ]]; then
    echo "Installing Zoom..."
    sudo mkdir -p /etc/apt/keyrings && wget -qO- https://mirror.mwt.me/my/gpgkey | sudo tee /etc/apt/keyrings/mwt.asc > /dev/null
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/mwt.asc by-hash=force] https://mirror.mwt.me/my/deb any zoom" | sudo tee /etc/apt/sources.list.d/mwt.list
    sudo apt update
    sudo apt install zoom -y
    sudo usermod -aG sudo aneesh
fi

echo "Setting default shell as fish..."
sudo chsh --shell /usr/bin/fish aneesh
echo "Copying files for second.sh..."
sudo mkdir /home/aneesh/paxxer
sudo cp $PAXXERDIR/second.sh /home/aneesh/paxxer
sudo cp $PAXXERDIR/.conkyrc /home/aneesh/paxxer
sudo cp $PAXXERDIR/conky-startup.desktop /home/aneesh/paxxer
sudo chmod +x /home/aneesh/paxxer/second.sh
sudo touch /etc/paxxer-first-done

if [[ "$ARCH" == "x86_64" ]]; then
    echo "Setting up boot screen (plymouth)..."
    echo ""
    echo "NOTE: This assumes you have installed Debian from the live edition,"
    echo "which has plymouth preinstalled."
    sudo apt install plymouth plymouth-themes -y
    cd /usr/share/plymouth/themes
    sudo git clone https://github.com/R0b1ns/brogit-plymouth-theme
    sudo plymouth-set-default-theme brogit-plymouth-theme -R
    echo $USER | sudo tee -a /etc/paxxer-user
    echo "Setting Hostname..."
    sudo hostnamectl set-hostname terra
    sudo hostname terra
    sudo sed -i "s/$CUR_HOSTNAME/terra/g" /etc/hosts
    sudo sed -i "s/$CUR_HOSTNAME/terra/g" /etc/hostname
    sleep 7
fi

echo "After rebooting, run the second.sh script in /home/aneesh/paxxer."
echo "NOTE: After rebooting, login as user aneesh, or the script will break."
echo ""
echo "Press any key to reboot..."
read -s -n 1
echo ""
echo "Pressed a key, rebooting..."
systemctl reboot
