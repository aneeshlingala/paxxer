PS3='Please select what distro you are using: '
options=("Debian" "Arch Linux" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Debian")
            echo "Starting Paxxer Debian"
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