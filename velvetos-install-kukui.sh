ARCH=$(uname -m)
echo "Running checks..."

if [[ $EUID -eq 0 ]]; then
echo "Error: Do not run this script as root!" 1>&2
echo "Solution: Run this script as a normal user without sudo."
exit
fi

if ping -q -c 1 -W 1 google.com >/dev/null; then
  echo "You are online, continuing..."
  echo ""
else
  echo "Error: You are offline."
  echo ""
  echo "Press any key to launch the Network Connection Wizard..."
  read -s -n 1
  echo ""
  echo "Pressed a key, launching the Network Connection Wizard..."
  nmtui
fi

if [[ "$ARCH" == "aarch64" ]]; then
    echo "Architecture is aarch64, continuing..."
else
    echo "The VelvetOS installer only works on the aarch64 architecture"
    exit
fi

echo "VelvetOS Installer"
echo "Version 2023.09.13"
echo "NOTE: Make sure you have run /scripts/extend-rootfs.sh for more space"
echo "Press CTRL + C to exit"
sleep 7
start=`date +%s`
cd ~
echo "Downloading installer image, this may take a while..."
sudo wget https://github.com/hexdump0815/imagebuilder/releases/download/230218-01/chromebook_kukui-aarch64-bookworm.img.gz
echo "Extracting installer image, this may take a while..."
sudo gzip -d chromebook_kukui-aarch64-bookworm.img.gz
echo "Where should VelvetOS be installed (eg. sda, mmcblk0, etc.): "  
read disk
echo "Installing VelvetOS to /dev/$(echo $disk)."
sudo dd if=chromebook_kukui-aarch64-bookworm.img of=/dev/$disk bs=1M status=progress
end=`date +%s`
echo "VelvetOS has been installed in `expr $end - $start` seconds."
echo ""
echo "Login with username: linux"
echo ""
echo "Password: changeme"
echo ""
echo "TIP: Run /scripts/extend-rootfs.sh to fill up all the disk space."
echo ""
echo "Reboot, then remove the USB/SD Card."
exit
