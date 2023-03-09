echo "Paxxer - Second Setup"
sudo nano /etc/apt/sources.list
sudo apt upgrade
sudo apt --fix-broken install
sudo apt reinstall base-files
sudo apt upgrade
sudo apt autoremove
sudo apt install runit-init
sudo apt remove init -y
cd ~
sudo rm -rf migration.sh
echo "You are done!"
