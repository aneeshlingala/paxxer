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
    echo "The VelvetOS installer only works on the aarch64 architecture"
    exit
fi

echo "VelvetOS LUKS Encrypted Installer"
echo "Version 2025.02.10"
echo "NOTE: Make sure you have run /scripts/extend-rootfs.sh for more space"
echo "If you have not, the script will run it for you, if it exists"

if [[ -f "/scripts/extend-rootfs.sh" ]]; then
    echo "The script extend-rootfs.sh exists, running it..."
    sudo bash /scripts/extend-rootfs.sh
else
    echo "The script extend-rootfs.sh does not exist, continuing..."
fi

sleep 7
start=`date +%s`
cd ~
echo "Installing to internal disk /dev/mmcblk0!"
export disk=mmcblk0
export part=mmcblk0p
sudo apt-get install cgpt -y
sudo sgdisk -Z /dev/${disk}
sudo partprobe /dev/${disk}
sudo sgdisk -C -e -G /dev/${disk}
sudo partprobe /dev/${disk}
sudo cgpt create /dev/${disk}
sudo partprobe /dev/${disk}
sudo cgpt add -i 1 -t kernel -b 8192 -s 65536 -l KernelA -S 1 -T 2 -P 10 /dev/${disk}
sudo cgpt add -i 2 -t kernel -b 73728 -s 65536 -l KernelB -S 0 -T 2 -P 5 /dev/${disk}
sudo apt install util-linux -y
clear
echo "MANUAL PARTITIONING"
echo "Make a 1GB Partition (make sure it is mmcblk0p3!)"
echo "Make a Partition filling the rest of the disk (make sure it is mmcblk0p4!)"
read -n 1 -s -r -p "Press any key to continue"
sudo cfdisk /dev/mmcblk0
sudo mkfs -t ext4 -O ^has_journal -m 0 -L bootemmc /dev/${part}3
sudo cryptsetup luksFormat /dev/${part}4
sudo cryptsetup open --type luks /dev/${part}4 encrypted
sudo mkfs -t btrfs -m single -L rootemmc /dev/mapper/encrypted
sudo mount -o ssd,compress-force=zstd,noatime,nodiratime /dev/mapper/encrypted /mnt
cd /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/${part}3 /mnt/boot
sudo rsync -axADHSX --no-inc-recursive --delete /boot/ /mnt/boot
sudo rsync -axADHSX --no-inc-recursive --delete --exclude='/swap/*' / /mnt
sudo rm -rf /mnt/etc/fstab
sudo touch /mnt/etc/fstab
echo "LABEL=rootemmc / btrfs defaults,ssd,compress-force=zstd,noatime,nodiratime 0 1" | sudo tee -a /mnt/etc/fstab
echo "LABEL=bootemmc /boot ext4 defaults 0 2" | sudo tee -a /mnt/etc/fstab
export uuid=$(sudo blkid -s UUID -o value /dev/mmcblk0p4)
sudo touch /mnt/etc/crypttab
echo "encrypted UUID=${uuid} none luks,discard" | sudo tee -a /mnt/etc/crypttab
sudo touch /mnt/etc/initramfs-tools/conf.d/compress
sudo chroot /mnt /bin/bash -c "sudo mount -t proc proc /proc"
sudo chroot /mnt /bin/bash -c "sudo mount -t sysfs sysfs /sys"
sudo mount --bind /dev /mnt/dev
sudo mount --bind /dev/pts/ /mnt/dev/pts/
sudo mount --bind /run /mnt/run
sudo cp /etc/resolv.conf /mnt/etc/
sudo chroot /mnt /bin/bash -c "cd /boot"
sudo chroot /mnt /bin/bash -c "sudo wget https://raw.githubusercontent.com/aneeshlingala/paxxer/refs/heads/paxxer/initrd.sh && sudo bash initrd.sh"
sudo chroot /mnt /bin/bash -c "sudo dd if=/boot/vmlinux.kpart-initrd-* of=/dev/mmcblk0p1"
sudo chroot /mnt /bin/bash -c "sudo dd if=/boot/vmlinux.kpart-initrd-* of=/dev/mmcblk0p2"
end=`date +%s`
echo "VelvetOS has finished installing in 'expr $end - $start' seconds!"
