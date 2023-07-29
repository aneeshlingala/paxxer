if [ "$(whoami)" != "aneesh" ]; then
        echo "Error: Please reboot and run the script as user aneesh."
        echo "Not rebooting but instead logging out and logging in as aneesh will cause the script to break."
        exit
fi

if [[ -f "/etc/paxxer-second" ]]; then
    echo "Second.sh has been run, good."
    sudo rm -rf /etc/paxxer-second
else
    echo "Error: Please run second.sh, then third.sh."
    exit
fi

echo "Upgrading to Debian Unstable..."
sudo rm -rf /etc/apt/sources.list
sudo touch /etc/apt/sources.list
echo "deb http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list
sudo apt update -y
echo "Note: Please check if apt is removing any necessary packages."
sudo apt full-upgrade --autoremove
sudo touch /etc/paxxer-successful
