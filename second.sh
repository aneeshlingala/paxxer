echo "Network Connection Wizard - Loading..."
sleep 3
nmtui
sudo chown -R aneesh:aneesh /home/aneesh
cd /home/aneesh/paxxer
echo "Cleaning up..."
cd ~
rm -rf /home/aneesh/paxxer
echo "Deleting user linux"
sudo userdel linux
sudo rm -rf /home/linux
echo "Setting GTK, Icon, Sound, and Cursor theme..."
xfconf-query -c xsettings -p /Net/ThemeName -s "Juno"
xfconf-query -c xsettings -p /Net/IconThemeName -s "beautyline"
xfconf-query --channel xsettings --property /Gtk/CursorThemeName --set oreo_teal_cursors
xfconf-query -c xsettings -p /Net/EnableEventSounds -s true
xfconf-query -c xsettings -p /Net/EnableInputFeedbackSounds -s true
xfconf-query -c xsettings -p /Net/SoundThemeName -s "Smooth"
xfconf-query -c xfwm4 -p /general/theme -s Nordic
xfconf-query -c xfwm4 -p /general/button_layout -s "CMH|O"
echo "Adding some things to autostart..."
mkdir ~/.config
mkdir ~/.config/autostart
cp conky.desktop ~/.config/autostart
cp startsound.desktop ~/.config/autostart
echo "Paxxer is done... rebooting."
systemctl reboot
