echo "Paxxer, a setup tool to setup my Debian system, to my liking."
echo "Supported Devices: Kukui Mediatek MT8183 ARM64 Chromebooks"
echo "Setting variables..."
PAXXERDIR=$PWD
echo "Extending rootfs to max..."
sudo bash /scripts/extend-rootfs.sh
sudo rm -rf /scripts
echo "Setting Hostname..."
sudo hostnamectl set-hostname kappa
sudo rm -rf /etc/hostname
echo "kappa" | sudo tee -a /etc/hostname
echo "Installing Smooth Sound Theme"
sudo cp -r Smooth /usr/share/sounds
echo "Setting up startup sound..."
sudo cp start.wav /usr/share/sounds
sudo cp startsound.desktop /etc/xdg/autostart
echo "To change sound theme, go to: https://wiki.archlinux.org/title/Xfce#Sound_themes"
echo "Installing Zafiro Icons, Oreo Cursors, extra tools and Nordic GTK Theme"
sudo apt install git wget curl orphan-sysvinit-scripts alsa-utils fish -y
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
cd /usr/share/icons
sudo tar -xzvf $PAXXERDIR/cursors.tar.gz -C .
cd ..
echo "Adding user Aneesh..."
sudo adduser aneesh
sudo passwd aneesh
sudo usermod -a -G sudo aneesh
echo "Setting default shell as fish"
sudo chsh --shell /usr/bin/fish aneesh
echo "Installing SDDM and setting it up..."
sudo apt install sddm
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
cd ~
echo "Installing Brave Browser..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser -y
sudo apt remove firefox firefox-esr
echo "Installing doas and removing sudo..."
sudo passwd
sudo apt install doas
echo "permit persist :aneesh :linux" | sudo tee -a /etc/doas.conf
sudo apt remove sudo
cd /usr/bin
doas wget https://raw.githubusercontent.com/jirutka/doas-sudo-shim/v0.1.1/sudo
doas chmod +x sudo
echo "Updating Kernel..."
sudo rm -rf /boot/*
cd ~
sudo wget "https://github.com/hexdump0815/linux-mainline-mediatek-mt81xx-kernel/releases/download/6.1.11-stb-mt8%2B/6.1.11-stb-mt8+.tar.gz"
sudo rm -rf /lib/modules/*
sudo tar -xzvf 6.1.11-stb-mt8+.tar.gz -C / 
sudo rm -rf 6.1.11-stb-mt8+.tar.gz
sudo dd if=/boot/vmlinux.kpart-6.1.11-stb-mt8+ of=/dev/mmcblk0p1
sudo dd if=/boot/vmlinux.kpart-6.1.11-stb-mt8+ of=/dev/mmcblk0p2
echo "Setting up autologin (only until next reboot)..."
sudo cp autologin.conf /etc/sddm.conf.d
echo "Migrating Debian to Devuan..."
sudo bash migration.sh
sudo rm -rf migration.sh
sudo mkdir /paxxer
sudo cp secondrun.desktop /home/aneesh/.config/autostart
sudo cp second.sh /paxxer
sudo cp sources.list /paxxer
sudo chmod +x /paxxer/second.sh
echo "Rebooting for the second part of the script to be run in 5 seconds..."
echo "NOTE: after rebooting, login as user Aneesh"
sleep 5
systemctl reboot
