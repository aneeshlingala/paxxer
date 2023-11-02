#!/bin/bash

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
    echo "The kernel updater installer only works on the aarch64 architecture"
    exit
fi

echo "Kukui Chromebook Kernel Updater"
echo "Version 2023.11.01"
echo "Updating kernel from $(echo $KERNEL) to 6.5.5-stb-mt8+"
sudo rm -rf /boot/*
sudo rm -rf /lib/modules/*
cd ~
sudo wget "https://github.com/hexdump0815/linux-mainline-mediatek-mt81xx-kernel/releases/download/6.5.5-stb-mt8%2B/6.5.5-stb-mt8+.tar.gz"
cd /
sudo tar -xzvf ~/6.5.5-stb-mt8+.tar.gz
sudo rm -rf 6.5.5-stb-mt8+.tar.gz
sudo dd if=/boot/vmlinux.kpart-6.5.5-stb-mt8+ of=/dev/mmcblk0p1 bs=1M status=progress
sudo dd if=/boot/vmlinux.kpart-6.5.5-stb-mt8+ of=/dev/mmcblk0p2 bs=1M status=progress
