if [[ $EUID -eq 0 ]]; then
echo "Error: Do not run this script as root!" 1>&2
echo "Solution: Please run it as a normal user without sudo."
fi
echo "Paxxer - Replacing Debian with Devuan (Part 2)..."
cd /paxxer
sudo rm -rf /etc/apt/sources.list
sudo cp sources.list /etc/apt
sudo dpkg --purge --force-all systemd
sudo apt update
sudo apt upgrade
sudo apt --fix-broken install
sudo apt reinstall base-files
sudo apt upgrade
sudo apt autoremove
sudo apt install runit-init
sudo apt remove init -y
echo "Setting GTK, Icon, Sound, and Cursor theme..."
xfconf-query -c xsettings -p /Net/ThemeName -s "Nordic"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Zafiro-Icons-Dark"
xfconf-query --channel xsettings --property /Gtk/CursorThemeName --set oreo_teal_cursors
xfconf-query -c xsettings -p /Net/EnableEventSounds -s true
xfconf-query -c xsettings -p /Net/EnableInputFeedbackSounds -s true
xfconf-query -c xsettings -p /Net/SoundThemeName -s "Smooth"
echo "Cleaning up..."
cd ~
sudo rm -rf /home/aneesh/paxxer
sudo rm -rf /home/aneesh/.config/autostart/secondrun.desktop
echo "Deleting user linux"
sudo userdel linux
sudo rm -rf /home/linux
echo "You are done! Rebooting to apply changes in 5 seconds..."
sleep 5
sudo loginctl reboot
