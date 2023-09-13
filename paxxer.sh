#!/bin/bash

PS3='What would you like to do?: '
options=("Install VelvetOS" "Setup Debian" "Setup Arch Linux" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install VelvetOS")
            echo "Starting Installer..."
            bash velvetos-install-kukui.sh
            ;;
        "Setup Debian")
            echo "Starting PaxxerDeb"
            bash first.sh
            ;;
        "Setup Arch Linux")
            echo "Starting PaxxerAL"
            bash first-archlinux.sh
            ;;
        "Quit")
            echo "Quitting..."
            exit
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done
