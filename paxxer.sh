#!/bin/bash

PS3='Please select the distro you are using: '
options=("Debian" "Arch Linux" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Debian")
            echo "Starting PaxxerDeb"
            bash first.sh
            ;;
        "Arch Linux")
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
