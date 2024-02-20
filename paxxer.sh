#!/bin/bash

PS3='What would you like to do?: '
options=("Setup Debian (ARM Chromebook ONLY)" "Setup Debian (Raspberry Pi OS Lite ONLY)" "Setup Arch Linux" "Install VelvetOS (Debian)" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Setup Debian (ARM Chromebook ONLY)")
            echo "Starting PaxxerDeb - ARM Chromebook Edition..."
            bash first.sh
            ;;
        "Setup Debian (Raspberry Pi ONLY)")
            echo "Starting PaxxerDeb - Raspberry Pi Edition..."
            bash first-rpi.sh
            ;;
        "Setup Arch Linux")
            echo "Starting PaxxerAL..."
            bash first-archlinux.sh
            ;;
        "Install VelvetOS (Debian)")
            echo "Starting Installer..."
            bash velvetos-install-kukui.sh
            ;;
        "Quit")
            echo "Quitting..."
            exit
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done
