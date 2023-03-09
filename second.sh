echo "Paxxer - Replacing Debian with Devuan..."
sudo rm -rf /etc/apt/sources.list
sudo cp sources.list /etc/apt
sudo apt update
sudo apt upgrade
sudo apt --fix-broken install
sudo apt reinstall base-files
sudo apt upgrade
sudo apt autoremove
sudo apt install runit-init
sudo apt remove init -y
cd ~
sudo rm -rf migration.sh
sudo rm -rf /paxxer
sudo rm -rf ~/.config/autostart/secondrun.desktop
echo "You are done!"
