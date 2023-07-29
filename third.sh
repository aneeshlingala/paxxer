echo "Upgrading to Debian Unstable..."
sudo rm -rf /etc/apt/sources.list
sudo touch /etc/apt/sources.list
echo "deb http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list
sudo apt update -y
echo "Note: Please check if apt is removing any necessary packages."
sudo apt full-upgrade --autoremove
