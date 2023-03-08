echo "Paxxer, a setup tool to setup my Debian system, to my liking."
echo "Supported Devices: Kukui Mediatek MT8183 Arm64 Chromebooks"
echo "Increasing size of the root filesystem to max..."
sudo bash /scripts/extend-rootfs.sh
sudo rm -rf /scripts
echo "Installing Zafiro icons, Bibata Cursors, and Layan GTK Theme"
sudo apt install git sassc wget curl orphan-sysvinit-scripts -y
cd ~
git clone https://github.com/vinceliuice/Layan-gtk-theme
cd Layan-gtk-theme
sudo bash install.sh
git clone https://github.com/zayronxio/Zafiro-icons
cd Zafiro-icons
sudo bash Install-Zafiro-Icons.sh
wget "http://ftp.us.debian.org/debian/pool/main/b/bibata-cursor-theme/bibata-cursor-theme_2.0.3-4_all.deb"
sudo dpkg -i bibata-cursor-theme_2.0.3-4_all.deb
sudo rm -rf bibata-cursor-theme_2.0.3-4_all.deb
cd ..
sudo rm -rf Layan-gtk-theme
echo "Adding user Aneesh..."
sudo useradd aneesh
sudo passwd aneesh
sudo usermod -a -G sudo aneesh
sudo userdel changeme
sudo rm -rf /home/changeme
echo "Installing SDDM and setting it up..."
sudo apt install sddm
sudo touch /etc/sddm.conf
echo "[Theme]" | sudo tee -a /etc/sddm.conf
echo "Current=chili" | sudo tee -a /etc/sddm.conf
echo "CursorTheme=Bibata-Modern-Amber" | sudo tee -a /etc/sddm.conf
cd /usr/share/sddm/themes
sudo git clone https://github.com/MarianArlt/sddm-chili chili 
cd chili
sudo rm -rf theme.conf
sudo wget "https://gist.githubusercontent.com/aneeshlingala/b731d9376f376021b5902bef8cd2a4ff/raw/b9a2575156a08d469e000156a6815988756c0e44/theme.conf"
sudo apt install qml-module-qtquick-controls qml-module-qtgraphicaleffects -y
cd ~
sudo wget https://git.devuan.org/farmatito/migration/raw/branch/master/migration.sh
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
echo "Last Step: Migrating Debian to Devuan"
sudo bash migration.sh
sudo nano /etc/apt/sources.list
sudo apt upgrade
sudo apt --fix-broken install
sudo apt reinstall base-files
sudo apt upgrade
sudo apt autoremove
sudo apt install runit-init init 
sudo rm -rf migration.sh
sudo reboot
echo "Once your done, customize Xfce!"