#!/bin/bash

PS3='What would you like to do?: '
options=("Setup Debian" "Setup Arch Linux" "Install VelvetOS (Debian)" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Setup Debian")
            echo "Starting PaxxerDeb"
            bash first.sh
            ;;
        "Setup Arch Linux")
            echo "Starting PaxxerAL"
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
