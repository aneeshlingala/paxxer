#!/bin/bash

echo "Setting variables..."
PAXXERDIR=$PWD
CUR_HOSTNAME=$(cat /etc/hostname)
ARCH=$(uname -m)

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

if [[ "$ARCH" == "aarch64" ]]; then
    echo "Architecture is aarch64, continuing..."
else
    echo "Error: Paxxer does not work on $(echo $ARCH) architecture."
fi

echo "PaxxerDeb, a setup tool to setup my Debian system, to my liking."
echo "Version: 2024.02.20"


if ! id -u aneesh > /dev/null 2>&1; then
    echo "Adding user Aneesh..."
    sudo adduser aneesh
    sudo usermod -a -G sudo aneesh
fi

echo "Setting root password..."
sudo passwd

if [[ "$ARCH" == "aarch64" ]]; then
    echo "Setting Hostname..."
    sudo hostnamectl set-hostname rpi4b
    sudo hostname rpi4b
    sudo sed -i "s/$CUR_HOSTNAME/rpi4b/g" /etc/hosts
    sudo sed -i "s/$CUR_HOSTNAME/rpi4b/g" /etc/hostname
fi

echo "Installing Deepin Sound Theme"
sudo apt update -y
sudo apt install gnome-session-canberra sox deepin-sound-theme -y
echo "Installing GitHub Desktop..."
cd ~
sudo wget https://github.com/shiftkey/desktop/releases/download/release-3.3.6-linux3/GitHubDesktop-linux-arm64-3.3.6-linux3.deb
sudo apt install ./GitHubDesktop-linux-arm64-3.3.6-linux3.deb -y
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
echo "Installing Brave Browser..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update -y
sudo apt install brave-browser firmware-intel-sound -y
cd ~
sudo git clone https://github.com/vinceliuice/Graphite-gtk-theme
cd Graphite-gtk-theme
sudo bash install.sh -t teal -c dark --tweaks nord 
cd ~
sudo git clone https://github.com/SylEleuth/gruvbox-plus-icon-pack
cd gruvbox-plus-icon-pack
sudo cp -r Gruvbox-Plus-Dark /usr/share/icons/
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
echo "Setting up Flatpak and installing GTKCord4 (Discord Client for Linux, supporting ARM64, built on GTK4)"
sudo apt install flatpak -y
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub so.libdb.gtkcord4 -y
echo "Installing MATE Desktop"
sudo apt install vlc eog simplescreenrecorder mousepad file-roller atril gnome-disk-utility mate-media-common mate-media mate-power-manager gnome-system-monitor mate-applets system-config-printer cups mate-desktop-environment-core telegram-desktop network-manager-gnome mate-calc mate-applet-brisk-menu mate-tweak --no-install-recommends -y
echo "Please enter in the root password..."
su -c "apt install sudo -y"
sudo apt remove synaptic lightdm-settings --autoremove -y
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
echo "Installing LightDM and setting it up..."
sudo apt install ukui-greeter lightdm -y
sudo rm -rf /etc/lightdm/lightdm.conf
sudo touch /etc/lightdm/lightdm.conf
echo "[SeatDefaults]" | sudo tee -a /etc/lightdm/lightdm.conf
echo "greeter-session=ukui-greeter" | sudo tee -a /etc/lightdm/lightdm.conf
sudo mkdir /usr/share/backgrounds
sudo mkdir /usr/share/backgrounds/debian-lights
sudo cp $PAXXERDIR/lights.png /usr/share/backgrounds/debian-lights/
cd ~
echo "Setting default shell as fish..."
sudo chsh --shell /usr/bin/fish aneesh
echo "Copying files for second-rpi.sh..."
sudo mkdir /home/aneesh/paxxer
sudo cp $PAXXERDIR/second-rpi.sh /home/aneesh/paxxer
sudo cp $PAXXERDIR/.conkyrc /home/aneesh/paxxer
sudo cp $PAXXERDIR/conky-startup.desktop /home/aneesh/paxxer
sudo chmod +x /home/aneesh/paxxer/second-rpi.sh
sudo touch /etc/paxxer-first-done
echo $USER | sudo tee -a /etc/paxxer-user
sudo rm -rf ~/gruvbox-plus-icon-pack ~/Graphite-gtk-theme ~/Bookshelf
sudo systemctl enable lightdm
echo "After rebooting, run the second-rpi.sh script in /home/aneesh/paxxer."
echo "NOTE: After rebooting, login as user aneesh, or the script will break."
echo ""
echo "Press any key to reboot..."
read -s -n 1
echo ""
echo "Pressed a key, rebooting..."
systemctl reboot
