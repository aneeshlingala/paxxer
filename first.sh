#!/bin/bash

echo "Setting variables..."
PAXXERDIR=$PWD
CUR_HOSTNAME=$(cat /etc/hostname)
KERNEL=$(uname -r)
ARCH=$(uname -m)

sudo apt install curl -y
clear
echo ""
echo "Announcements from Paxxer Developers:"
echo ""
curl -s https://raw.githubusercontent.com/aneeshlingala/paxxer/paxxer/announcements | cat
echo ""
echo "Press the spacebar to exit announcements..."
read -r -s -d ' '
echo ""

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
echo "Version: 2025.02.09"

if [[ -f "/scripts/extend-rootfs.sh" ]]; then
    echo "The script extend-rootfs.sh exists, running it..."
    sudo bash /scripts/extend-rootfs.sh
else
    echo "The script extend-rootfs.sh does not exist, continuing..."
fi

if [[ "$USER" == "linux" ]]; then
    echo "Fixing Permissions..."
    sudo find /bin /boot /etc /lib /opt /root /sbin /usr -user linux -exec sudo chmod g-w {} \;
    sudo find /bin /boot /etc /lib /opt /root /sbin /usr -user linux -exec sudo chown root:root {} \;
    sudo find /bin /boot /etc /lib /opt /root /sbin /usr -user linux -type l -exec sudo chown -h root:root {} \;
    sudo chmod g-w /
    sudo chown root:root /
fi

if ! id -u aneesh > /dev/null 2>&1; then
    echo "Adding user Aneesh..."
    sudo adduser aneesh
    sudo usermod -a -G sudo aneesh
    echo "Setting root password..."
    sudo passwd
fi
if [[ "$ARCH" == "aarch64" ]]; then
    echo "Setting Hostname..."
    sudo hostnamectl set-hostname kappa
    sudo hostname kappa
    sudo sed -i "s/$CUR_HOSTNAME/kappa/g" /etc/hosts
    sudo sed -i "s/$CUR_HOSTNAME/kappa/g" /etc/hostname
    curl -sS https://repo.velvet-os.org/repo/velvet_repo.asc | sudo tee -a /etc/apt/trusted.gpg.d/velvet_repo.asc
    echo "deb [arch=arm64,all] https://repo.velvet-os.org/repo stable main" | sudo tee /etc/apt/sources.list.d/velvet_repo.list
    sudo apt update
    sudo apt install linux-6.12.5-stb-cbm+ -y
    sudo vtbuild 6.12.5-stb-cbm+
    sudo vtflash 6.12.5-stb-cbm+ /dev/mmcblk0
    sudo rm -rf /etc/velvettools/config
    sudo cp $PAXXERDIR/config /etc/velvettools/
    sudo update-initramfs -c -k 6.12.5-stb-cbm+
fi

echo "Installing Deepin Sound Theme"
sudo apt update -y
sudo apt install gnome-session-canberra sox deepin-sound-theme -y
echo "Installing GitHub Desktop..."
cd ~
sudo wget https://github.com/shiftkey/desktop/releases/download/release-3.3.6-linux3/GitHubDesktop-linux-arm64-3.3.6-linux3.deb
sudo apt install ./GitHubDesktop-linux-arm64-3.3.6-linux3.deb
sudo rm -rf GitHubDesktop-linux-arm64-3.3.6-linux3.deb
sudo mkdir /home/aneesh/GitHub
sudo chown aneesh:aneesh /home/aneesh/GitHub
echo "Removing Libreoffice, this may take a while..."
sudo apt remove libreoffice* --autoremove -y
sudo apt purge gimp xterm hv3 --autoremove -y
echo "Installing Candy Icon Theme, Afterglow Cursors, extra tools, and Graphite GTK Theme"
sudo apt install git wget curl sassc alsa-utils fish w3m fonts-noto-color-emoji xdotool ntpsec -y
sudo apt purge firefox-esr vim vim-tiny plymouth --autoremove -y
sudo apt remove xarchiver --autoremove -y
cd ~
sudo git clone https://github.com/vinceliuice/Graphite-gtk-theme
cd Graphite-gtk-theme
sudo bash install.sh -t teal -c dark --tweaks nord 
cd ~
sudo git clone https://github.com/SylEleuth/gruvbox-plus-icon-pack
cd gruvbox-plus-icon-pack
sudo cp -r Gruvbox* /usr/share/icons/
cd ~
sudo git clone https://github.com/yeyushengfan258/Afterglow-Cursors
cd Afterglow-Cursors
sudo bash install.sh
cd ~
sudo rm -rf Afterglow-Cursors
echo "Setting timezone to America/Los Angeles"
sudo rm -rf /etc/timezone
touch /etc/timezone
sudo timedatectl set-timezone America/Los_Angeles
sudo apt install lsb-release
curl -q 'https://proget.makedeb.org/debian-feeds/prebuilt-mpr.pub' | gpg --dearmor | sudo tee /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg 1> /dev/null
echo "deb [signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] https://proget.makedeb.org prebuilt-mpr $(lsb_release -cs)" | sudo tee /etc/apt/sources.list.d/prebuilt-mpr.list
sudo apt update
sudo apt install prismlauncher openjdk-17-jdk -y

if [[ "$ARCH" == "aarch64" ]]; then
    echo "Installing Java..."
    echo "LIBGL_ALWAYS_SOFTWARE=true" | sudo tee -a /etc/environment
    cd ~
    wget https://download.bell-sw.com/java/21.0.4+9/bellsoft-jdk21.0.4+9-linux-aarch64.deb
    sudo apt install ./bellsoft-jdk21.0.4+9-linux-aarch64.deb
fi

if [[ "$ARCH" == "x86_64" ]]; then
    echo "Installing Java..."
    echo "LIBGL_ALWAYS_SOFTWARE=true" | sudo tee -a /etc/environment
    cd ~
    wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb
    sudo dpkg -i jdk-21_linux-x64_bin.deb
fi

echo "Upgrading System..."
sudo apt upgrade --autoremove -y
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean
echo "Replacing Xfce Desktop with KDE..."
cd ~
sudo apt download network-manager -y
sudo apt install kde-plasma-desktop gwenview simplescreenrecorder file-roller atril telegram-desktop plasma-systemmonitor cups network-manager-gnome kcalc -y
sudo apt install task-kde-desktop --no-install-recommends -y
sudo apt-get purge xfconf xfce4-utils xfwm4 xfce4-session xfdesktop4 exo-utils xfce4-panel xfce4-terminal gnome-system-tools thunar libxfce4ui* *xfce* -y
sudo apt purge network-manager -y
sudo dpkg -i ~/network* 
echo "Waiting for network to come back (15 seconds)..."
sleep 15
echo "Installing KDE Themes..."
cd ~
sudo git clone https://github.com/vinceliuice/Graphite-kde-theme
cd Graphite-kde-theme
sudo bash install.sh
cd ~
echo "Please enter in the root password..."
su -c "apt install sudo -y"
sudo apt remove xterm exfalso synaptic lightdm-settings imagemagick --autoremove -y
echo "Installing Brave Browser..."
sudo apt install curl -y
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser -y
echo "Installing Visual Studio Code..."
sudo apt-get install wget gpg
sudo wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=arm64,amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo rm -rf packages.microsoft.gpg
sudo apt update
sudo apt install code -y
sudo mkdir /home/aneesh/VSCode
sudo chown aneesh:aneesh /home/aneesh/VSCode
echo "Installing SDDM and setting it up..."
sudo systemctl disable lightdm
sudo apt purge lightdm -y --autoremove
sudo apt install --no-install-recommends qml-module-qtquick-layouts qml-module-qtquick-controls2 libqt6svg6 -y
sudo apt install kwin-x11 -y
sudo apt install kwin-wayland plasma-workspace-wayland -y
sudo systemctl enable sddm
sudo apt-get install plasma-nm unzip -y
echo "Adding Debian Backgrounds..."
sudo mkdir /usr/share/backgrounds
sudo mkdir /usr/share/backgrounds/debian-lights
sudo cp $PAXXERDIR/lights.png /usr/share/backgrounds/debian-lights/
cd ~
sudo apt purge mlterm mlterm-tiny xiterm+thai --autoremove

if [[ "$ARCH" == "x86_64" ]]; then
    sudo usermod -aG sudo aneesh
    echo "Installing Zoom..."
    sudo flatpak install flathub us.zoom.Zoom -y
fi

echo "Setting default shell as fish..."
sudo chsh --shell /usr/bin/fish aneesh
echo "Copying files for second.sh..."
sudo mkdir /home/aneesh/paxxer
sudo cp $PAXXERDIR/second.sh /home/aneesh/paxxer
sudo cp $PAXXERDIR/mcpi.desktop /home/aneesh/paxxer
sudo chmod +x /home/aneesh/paxxer/second.sh
sudo touch /etc/paxxer-first-done

if [[ "$ARCH" == "x86_64" ]]; then
    echo $USER | sudo tee -a /etc/paxxer-user
    echo "Setting Hostname..."
    sudo hostnamectl set-hostname terra
    sudo hostname terra
    sudo sed -i "s/$CUR_HOSTNAME/terra/g" /etc/hosts
    sudo sed -i "s/$CUR_HOSTNAME/terra/g" /etc/hostname
    sleep 7
    echo "Installing rEFInd..."
    sudo apt install refind -y
    sudo refind-install
    curl -sL https://git.io/refind-theme-nord | bash
    sudo rm -rf /boot/efi/EFI/debian
    sudo rm -rf /boot/efi/EFI/BOOT
    sudo rm -rf /boot/grub
    sudo refind-mkdefault
    sudo cp $PAXXERDIR/mcpi.desktop /usr/share/applications/
fi

if [[ "$ARCH" == "aarch64" ]]; then
    sudo vtbuild 6.12.5-stb-cbm+
    sudo vtflash 6.12.5-stb-cbm+ /dev/mmcblk0
    sudo update-initramfs -c -k 6.12.5-stb-cbm+
    sudo bash /boot/kernel-and-initrd.sh
    sudo dd if=/boot/vmlinux.kpart-initrd-6.12.5-stb-cbm+ of=/dev/mmcblk0p1 bs=1M status=progress
    sudo dd if=/boot/vmlinux.kpart-initrd-6.12.5-stb-cbm+ of=/dev/mmcblk0p2 bs=1M status=progress

fi

sudo rm -rf ~/gruvbox-plus-icon-pack ~/Graphite-gtk-theme
sudo cp $PAXXERDIR/mcpi.png /usr/share/pixmaps/
echo "After rebooting, run the second.sh script in /home/aneesh/paxxer."
echo "NOTE: After rebooting, login as user aneesh, or the script will break."
echo ""
echo "Press any key to reboot..."
read -s -n 1
echo ""
echo "Pressed a key, rebooting..."
systemctl reboot
