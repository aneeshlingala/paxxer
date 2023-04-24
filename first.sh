echo "Paxxer, a setup tool to setup my Debian system, to my liking."
echo "Supported Devices: Kukui Mediatek MT8183 ARM64 Chromebooks"
echo "Increasing size of the root filesystem to max..."
sudo bash /scripts/extend-rootfs.sh
sudo rm -rf /scripts
echo "Setting Hostname..."
sudo hostnamectl set-hostname kappa
echo "Installing Smooth Sound Theme"
sudo cp -r Smooth /usr/share/sounds
echo "Setting up startup sound..."
sudo cp start.wav /usr/share/sounds
echo "To change sound theme, go to: https://wiki.archlinux.org/title/Xfce#Sound_themes"
echo "Installing Zafiro Icons, Bibata Cursors, and Nordic GTK Theme"
sudo apt install git wget curl orphan-sysvinit-scripts -y
cd ~
cd /usr/share/themes
sudo git clone https://github.com/eliverlara/Nordic
cd ~
git clone https://github.com/zayronxio/Zafiro-icons
cd Zafiro-icons
sudo mv Dark /usr/share/icons/Zafiro-Icons-Dark
sudo mv Light /usr/share/icons/Zafiro-Icons-Dark
cd ..
rm -rf Zafiro-icons
wget "http://ftp.us.debian.org/debian/pool/main/b/bibata-cursor-theme/bibata-cursor-theme_2.0.3-4_all.deb"
sudo dpkg -i bibata-cursor-theme_2.0.3-4_all.deb
sudo rm -rf bibata-cursor-theme_2.0.3-4_all.deb
cd ..
echo "Adding user Aneesh..."
sudo adduser aneesh
sudo passwd aneesh
sudo usermod -a -G sudo aneesh
sudo userdel changeme
sudo rm -rf /home/changeme
echo "Installing SDDM and setting it up..."
sudo apt install sddm
sudo touch /etc/sddm.conf
echo "[Theme]" | sudo tee -a /etc/sddm.conf
echo "Current=chili" | sudo tee -a /etc/sddm.conf
echo "CursorTheme=Bibata-Original-Amber" | sudo tee -a /etc/sddm.conf
cd /usr/share/sddm/themes
sudo git clone https://github.com/MarianArlt/sddm-chili chili 
cd chili
sudo rm -rf theme.conf
sudo wget "https://gist.githubusercontent.com/aneeshlingala/b731d9376f376021b5902bef8cd2a4ff/raw/b9a2575156a08d469e000156a6815988756c0e44/theme.conf"
sudo apt install qml-module-qtquick-controls qml-module-qtgraphicaleffects -y
cd ~
echo "Installing Brave Browser..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser -y
echo "Updating Kernel..."
sudo rm -rf /boot/*
cd ~
sudo wget "https://github.com/hexdump0815/linux-mainline-mediatek-mt81xx-kernel/releases/download/6.1.11-stb-mt8%2B/6.1.11-stb-mt8+.tar.gz"
sudo rm -rf /lib/modules/*
sudo tar -xzvf 6.1.11-stb-mt8+.tar.gz -C / 
sudo rm -rf 6.1.11-stb-mt8+.tar.gz
sudo dd if=/boot/vmlinux.kpart-6.1.11-stb-mt8+ of=/dev/mmcblk0p1
sudo dd if=/boot/vmlinux.kpart-6.1.11-stb-mt8+ of=/dev/mmcblk0p2
echo "Migrating Debian to Devuan..."
sudo bash migration.sh
sudo rm -rf migration.sh
sudo mkdir /paxxer
sudo cp secondrun.desktop /home/aneesh/.config/autostart
sudo cp second.sh /paxxer
sudo cp sources.list /paxxer
sudo chmod +x /paxxer/second.sh
echo "Rebooting for Second Script to be run in 5 seconds..."
echo "NOTE: after rebooting, login as user Aneesh"
sleep 5
sudo reboot
