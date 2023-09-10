#!/bin/bash

echo "Setting variables..."
PAXXERDIR=$PWD
CUR_HOSTNAME=$(cat /etc/hostname)
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
fi

if [[ "$ARCH" == "x86_64" ]]; then
    echo "Architecture is x64, continuing..."
else
    echo "Error: Paxxer does not work on the $(echo $ARCH) architecture."
    exit
fi

echo "PaxxerAL, a setup tool to setup my Arch Linux system, to my liking."
echo "Version: 2023.09.09"

echo "Adding user Aneesh..."
sudo useradd aneesh
sudo mkdir /home/aneesh
sudo usermod -a -G wheel aneesh
echo "Setting root password..."
sudo passwd

if [[ "$ARCH" == "aarch64" ]]; then
    echo "Setting Hostname..."
    sudo hostnamectl set-hostname kappa
    sudo hostname kappa
    sudo sed -i "s/$CUR_HOSTNAME/kappa/g" /etc/hosts
    sudo sed -i "s/$CUR_HOSTNAME/kappa/g" /etc/hostname
fi

if [[ "$ARCH" == "x86_64" ]]; then
    echo "Installing Deepin Sound Theme"
    sudo pacman -Sy
    sudo pamcan -S deepin-sound-theme
fi

echo "Installing Kora Icon Theme, Afterglow Cursors, extra tools, and Juno GTK Theme"
sudo pacman -S git wget curl sassc alsa-utils fish w3m noto-fonts-emoji xdotool rhythmbox
sudo pacman -Rcns firefox vim vim-tiny plymouth
echo "Installing Brave Browser..."

if [[ "$ARCH" == "x86_64" ]]; then
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    echo "" | sudo tee -a /etc/pacman.conf
    echo "[chaotic-aur]" | sudo tee -a /etc/pacman.conf
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
    sudo pacman -Sy
    sudo pacman -S brave
fi

if [[ "$ARCH" == "aarch64" ]]; then
    git clone https://aur.archlinux.org/paru-bin.git
    cd paru-bin
    sudo pacman -S fakeroot
    makepkg -si
    paru -Sy
    paru -S brave-bin
fi

cd ~
cd /usr/share/themes
sudo git clone https://github.com/eliverlara/Juno
cd ~
sudo git clone https://github.com/bikass/kora
cd kora
sudo cp -r kora-* /usr/share/icons
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
sudo pacman -S totem eog mousepad file-roller atril gnome-disk-utility gnome-system-monitor mate-applets network-manager-applet system-config-printer cups telegram-desktop mate mate-applet-dock mate-calc
sudo pacman –Rsu xfce4

if pacman -Qi xfce4-goodies &> /dev/null; then
  sudo pacman -Rcns xfce4-goodies
fi

echo "Installing LXDM and setting it up..."
sudo pacman -S lxdm-gtk3
sudo systemctl disable lightdm.service
sudo systemctl enable lxdm.service
sudo mkdir /usr/share/backgrounds
sudo mkdir /usr/share/backgrounds/archlinux
sudo cp $PAXXERDIR/archlinux.jpg /usr/share/backgrounds/archlinux/
cd ~

if [[ "$ARCH" == "x86_64" ]]; then
    echo "Installing Zoom..."
    sudo pacman -S zoom
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
    echo "Installing rEFInd and removing Grub..."
    echo "Select yes in the next prompt, or the script will break."
    sleep 7
    sudo pacman -S refind
    sudo refind-install
    sudo pacman -Rcns grub
    sudo rm -rf /boot/grub
    cd /boot
    sudo mount /boot/efi
    sudo rm -rf efi/EFI/arch*
    cd ~
    curl -sL https://git.io/refind-theme-nord | bash
    sudo efibootmgr
    sleep 6
    read -p "Enter the last number of the boot entry (eg. 1, 2, 3, etc.) labeled Arch: " entry
    sudo efibootmgr -b $(echo $entry) -B
    echo $USER | sudo tee -a /etc/paxxer-user
    echo "Setting Hostname..."
    sudo hostnamectl set-hostname terra
    sudo hostname terra
    sudo sed -i "s/$CUR_HOSTNAME/terra/g" /etc/hosts
    sudo sed -i "s/$CUR_HOSTNAME/terra/g" /etc/hostname
    echo "After rebooting, make sure to boot into the rEFInd Boot Manager entry, not the Arch entry."
    sleep 7
fi

echo "After rebooting, run the second-archlinux.sh script in /home/aneesh/paxxer."
echo "NOTE: After rebooting, login as user aneesh, or the script will break."
echo ""
echo "Press any key to reboot..."
read -s -n 1
echo ""
echo "Pressed a key, rebooting..."
systemctl reboot
