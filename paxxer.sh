#!/bin/sh

if [ -f "$PWD/second.sh" ]; then
    echo "Script is running from the root directory of the repository, continuing..."
else
    echo "Error: Please run this script from the Paxxer repository."
    exit 1
fi

echo "Paxxer Launcher, Version 2025.02.10"
echo "What would you like to do?: "
echo "1) Setup Debian (ARM Chromebook/Generic x64 ONLY)"
echo "2) Setup Debian (Raspberry Pi ONLY)"
echo "3) Setup PostmarketOS (Use the installation image with console desktop!)"
echo "4) Quit"

while :
do
    read choice
    case $choice in
        1)
            echo "Starting PaxxerDeb - ARM Chromebook/Generic x64 Edition..."
            bash first.sh
            break
            ;;
        2)
            echo "Starting PaxxerDeb - Raspberry Pi Edition..."
            bash first-rpi.sh
            break
            ;;

        3)
            echo "Starting PaxxerPmOS..."
            echo y | sudo apk add bash
            bash first-pmos.sh
            break
            ;;
        4)
            echo "Quitting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please enter a number from 1 to 6."
            ;;
    esac
done
