echo "Paxxer - Replacing Debian with Devuan..."
cd /paxxer
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
echo "Cleaning up..."
cd ~
sudo rm -rf /paxxer
sudo rm -rf /home/aneesh/.config/autostart/secondrun.desktop
echo "Deleting user linux"
sudo userdel linux
sudo rm -rf /home/linux
echo "Removing autologin..."
sudo rm -rf /etc/sddm.conf.d/autologin.conf
echo "You are done! Rebooting to apply changes in 5 seconds..."
sleep 5
sudo loginctl reboot
