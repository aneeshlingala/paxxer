#!/bin/sh
#############################################################
# Debian to Devuan Migrator v.1.9-alfa for desktops         #
#                                                           #
# farmatito (c) 2021 <farmatito@tiscali.it> GPLv2           #
# Script to migrate a standard debian install to devuan     #
# Supported OS versions:                                    #
# a) Debian buster to Devuan beowulf                        #
# b) Debian bullseye to Devuan chimaera                     #
#                                                           #
# Supported DE's:                                           #
# 1) GNOME/GNOME FLASHBACK                                  #
# 2) LXDE                                                   #
# 3) LXQT                                                   #
# 4) XFCE                                                   #
# 5) KDE                                                    #
# 6) MATE                                                   #
# 7) CINNAMON                                               #
#                                                           #
# also SERVER migration is possible but risky. You really   #
# want to do it manually if you are not sitting in the same #
# room with the server. You have been warned!               #
#############################################################

FOUND_DE=0
SERVER=0
GNOME=0
GNOME_FLASHBACK=0
LXDE=0
LXQT=0
XFCE=0
KDE=0
MATE=0
CINNAMON=0
NETWORK=0
INSTALL_DBUS=0
INSTALL_NM=0
INSTALL_NM_GNOME=0
INSTALL_NM_KDE=0
_CONTRIB=""
_NONFREE=""

. /etc/os-release

# Prepare for next Debian release and detect version
if test "x$VERSION_ID" = "x10" ; then
	echo "Detected: Debian $VERSION"
	DEVUAN_CODENAME="beowulf"
	LIBPLYMOUTH="libplymouth4"
	IIO_SENSORS_PROXY="iio-sensor-proxy"
	SYSTEMD_TIMESYNCD=""
	INSTALL_DEBIAN_PULSEAUDIO_CONFIG_OVERRIDE=1
	INSTALL_GNOME_SCREENSAVER=0
	PAD=" "
elif test "x$VERSION_ID" = "x11" ; then
	echo "Detected: Debian $VERSION"
	DEVUAN_CODENAME="chimaera"
	LIBPLYMOUTH="libplymouth5"
	IIO_SENSORS_PROXY=""
	SYSTEMD_TIMESYNCD="systemd-timesyncd"
	INSTALL_DEBIAN_PULSEAUDIO_CONFIG_OVERRIDE=0
	PAD=""
else
	echo "Unsupported Debian Version: $VERSION"
	echo "Exiting..."
	exit 1
fi

# PROGRAMS NEEDED
# TODO test if all needed programs are there (Paranoia)

# CURRENT DEVUAN KEYRING PACKAGE
DEVUAN_KEYRING="devuan-keyring_2017.10.03_all.deb"

# SET PATH
export PATH=$PATH:/usr/sbin:/sbin

# CHECK FOR ROOT
ID=$(id -u)
if test "$ID" -ne 0 ; then
	echo "You need root permissions to run this script. Exiting..."
	exit 1
fi

# TEST NETWORK AS MIGRATION WILL FAIL IF NOT ONLINE
NETWORK=$(printf "GET /nm HTTP/1.1\\r\\nHost: network-test.debian.org\\r\\n\\r\\n" | nc -w1 network-test.debian.org 80 | grep -c "NetworkManager is online")
if test "$NETWORK" -ne 1 ; then
	NETWORK=$(printf "GET /ncsi.txt HTTP/1.1\\r\\nHost: www.msftncsi.com\\r\\n\\r\\n" | nc -w1 www.msftncsi.com 80 | grep -c "Microsoft NCSI")
	if test "$NETWORK" -ne 1 ; then
		echo "Your network seems to be down. "
		echo "Cannot connect to the Internet. Exiting..."
		exit 1
	fi
fi
#echo "Network Connectivity Status: OK"

# DISCLAIMER #
echo "Warning use at your own risk. BACKUP YOUR DATA FIRST!!!"
echo "Are you sure? [y|n]"
read -r ANS
if test "x$ANS" != "xy" -a "x$ANS" != "xY"; then
	exit 0
fi

# ntpdate is deprecated in debian but still exists in
# bullseye repos so we still use it here.
# In the future we will  need to switch to
# ntpsec-ntpdate or sntp -S pool.ntp.org
# this is less ideal as they have more dependencies.
# INSTALL NTPDATE IF NEEDED
NTPDATE=$(command -v ntpdate-debian)
if test -x "$NTPDATE" ; then
	echo "ntpdate-debian is already installed...good"
	# Wrong date and time is one of the causes of failure of apt update
	# and subsequent devuan deb packages download which breaks
	# the migration process, so we ensure that date and time are set correctly
else
	echo "Installing ntpdate-debian"
	apt install ntpdate > /dev/null 2>&1
fi
echo "Setting date and time with ntpdate-debian"
ntpdate-debian pool.ntp.org
# Allow time change to propagate
sleep 5
# INSTALL WGET IF NEEDED
WGET=$(command -v wget)
if test -x "$WGET" ; then
	echo "wget is already installed...good"
else
	echo "Installing wget"
	apt install wget > /dev/null 2>&1
fi

# DOWNLOAD DEVUAN KEYRING AND IMPLICIT TEST FOR NETWORK
echo "Downloading Devuan Keyring: $DEVUAN_KEYRING"
wget http://deb.devuan.org/devuan/pool/main/d/devuan-keyring/"$DEVUAN_KEYRING"  > /dev/null 2>&1
if test $? -ne 0 ; then
	echo "Could not download Devuan Keyring: $DEVUAN_KEYRING"
	echo "Exiting..."
	exit 1
fi

# DETECT INSTALLED DESKTOP ENVIRONMENTS
dpkg -L task-gnome-desktop > /dev/null 2>&1
if test $? -eq 0 ; then
	echo "Detected GNOME DE"
	GNOME=1
	FOUND_DE=1
	INSTALL_DBUS=1
	INSTALL_NM=1
	INSTALL_NM_GNOME=1
	if test "x$VERSION_ID" = "x11" ; then
		INSTALL_GNOME_SCREENSAVER=1
	fi
	# USES GDM3 but is problematic install slim instead
fi

dpkg -L task-gnome-flashback-desktop > /dev/null 2>&1
if test $? -eq 0 ; then
	echo "Detected GNOME FLASHBACK DE"
	GNOME=1
	GNOME_FLASHBACK=1
	FOUND_DE=1
	INSTALL_DBUS=1
	INSTALL_NM=1
	INSTALL_NM_GNOME=1
	INSTALL_GNOME_SCREENSAVER=1
	# USES GDM3 but is problematic install slim instead
fi

dpkg -L task-lxde-desktop > /dev/null 2>&1
if test $? -eq 0 ; then
	echo "Detected LXDE DE"
	LXDE=1
	FOUND_DE=1
	INSTALL_DBUS=1
	# USES CONNMAN in debian 11
	# USES WICD in debian 10
fi

dpkg -L task-lxqt-desktop > /dev/null 2>&1
if test $? -eq 0 ; then
	echo "Detected LXQT DE"
	LXQT=1
	FOUND_DE=1
	INSTALL_DBUS=1
	# USES CONNMAN in debian 11 and debian 10
	# USES SDDM but is problematic install slim instead
fi

dpkg -L task-xfce-desktop > /dev/null 2>&1
if test $? -eq 0 ; then
	echo "Detected XFCE DE"
	XFCE=1
	FOUND_DE=1
	INSTALL_DBUS=1
	INSTALL_NM=1
	INSTALL_NM_GNOME=1
fi

dpkg -L task-kde-desktop > /dev/null 2>&1
if test $? -eq 0 ; then
	echo "Detected KDE DE"
	KDE=1
	FOUND_DE=1
	INSTALL_DBUS=1
	INSTALL_NM=1
	INSTALL_NM_KDE=1
	# USES SDDM but is problematic install slim instead
fi

dpkg -L task-mate-desktop > /dev/null 2>&1
if test $? -eq 0 ; then
	echo "Detected MATE DE"
	MATE=1
	FOUND_DE=1
	INSTALL_DBUS=1
	INSTALL_NM=1
	INSTALL_NM_GNOME=1
fi

dpkg -L task-cinnamon-desktop > /dev/null 2>&1
if test $? -eq 0 ; then
	echo "Detected CINNAMON DE"
	CINNAMON=1
	FOUND_DE=1
	INSTALL_DBUS=1
	INSTALL_NM=1
	INSTALL_NM_GNOME=1
fi

if test $FOUND_DE -eq 0 ; then
	SERVER=1
	echo "No supported Desktop Environment detected!"
	echo "Is this a server?"
	echo "If you are logged in remotely with SSH be aware"
	echo "that the network might not work on reboot!"
	echo "Are you sure you want to continue? [y|n]"
	read -r ANS
	if test "x$ANS" != "xy" -a "x$ANS" != "xY"; then
		exit 0
	fi
fi

# RESTORE OLD SU BEHAVIOUR - no keep as before
#echo "ALWAYS_SET_PATH yes" > /etc/default/su

echo "Do you want contrib repos to be included in your apt sources? [y|n]"
read -r ANS
if test "x$ANS" = "xy" -o "x$ANS" = "xY"; then
	_CONTRIB=" contrib"
fi

echo "Do you want non-free repos to be included in your apt sources? [y|n]"
read -r ANS
if test "x$ANS" = "xy" -o "x$ANS" = "xY"; then
	_NONFREE=" non-free"
fi

# ADD DEVUAN REPOS
# TODO use mktemp /etc/apt/sources.list.d/XXXXXXXXX here and
# only add to sources.list if migration is successful?
# Cleanup in case of failure would be easier this way.
# TODO add also deb-src repos?
{ echo ""; \
  echo "deb http://deb.devuan.org/merged $DEVUAN_CODENAME main$_CONTRIB$_NONFREE"; \
  echo "deb http://deb.devuan.org/merged $DEVUAN_CODENAME-updates main$_CONTRIB$_NONFREE"; \
  echo "deb http://deb.devuan.org/merged $DEVUAN_CODENAME-security main$_CONTRIB$_NONFREE"; } >> /etc/apt/sources.list

# PIN PREFERENCE FOR DEVUAN PACKGES
# TODO use mktemp /etc/apt/preferences.d/XXXXXXXXX ?
{ echo "Package: *"; \
  echo "Pin: origin \"deb.devuan.org\""; \
  echo "Pin-Priority: 900"; } > /etc/apt/preferences.d/"$DEVUAN_CODENAME"

# STOP THE TIMERS FOR APT TO AVOID INTERFERENCES (FILE LOCKS)
systemctl stop apt-daily.timer
systemctl stop apt-daily-upgrade.timer

# INSTALL DEVUAN KEYRING
echo "Installing $DEVUAN_KEYRING"
dpkg -i "$DEVUAN_KEYRING" > /dev/null 2>&1
rm -f "$DEVUAN_KEYRING"

# UPDATE
echo "Update repos"
apt update > /dev/null 2>&1

# INSTALL DEVUAN PACKAGES TO INIT MIGRATION
if test $GNOME -eq 1 ; then
	echo "* Select slim as Display manager when prompted!                               *"
	echo "* Hit Enter to continue                                                       *"
	read -r DUMMY
	echo "Installing task-gnome-desktop"
	apt install task-gnome-desktop --no-install-recommends -y  > /dev/null 2>&1
	echo "Installing slim DM"
	apt install slim -yq
	# gnome-screensaver is needed because in bullseye screen locking
	# is builtin in gdm3
	if test $INSTALL_GNOME_SCREENSAVER -eq 1 ; then
		echo "Installing gnome-screensaver" 
		apt install gnome-screensaver -y  > /dev/null 2>&1
		# add autostart entry for gnome-screensaver
		ln -s /usr/share/applications/gnome-screensaver.desktop /etc/xdg/autostart/gnome-screensaver.desktop
	fi
	# DISABLE GDM3 TO AVOID BLACK SCREEN AT REBOOT - PARANOIA
	systemctl disable gdm3
fi

if test $GNOME_FLASHBACK -eq 1 ; then
	echo "Installing task-gnome-flashback-desktop"
	apt install task-gnome-flashback-desktop --no-install-recommends -y  > /dev/null 2>&1
fi

if test $LXDE -eq 1 ; then
	echo "Install task-lxde-desktop"
	apt install task-lxde-desktop -y > /dev/null 2>&1
	# uses wicd in debian 10 and connman in debian 11
fi

if test $LXQT -eq 1 ; then
	echo "Installing task-lxqt-desktop"
	apt install task-lxqt-desktop --no-install-recommends -y > /dev/null 2>&1
	echo "* Select slim as Display manager when prompted!                               *"
	echo "* Hit Enter to continue                                                       *"
	read -r DUMMY
	echo "Installing slim DM"
	apt install slim -yq
	# PARANOIA
	systemctl disable sddm
fi

if test $XFCE -eq 1 ; then
	# Don't install recommends for task-xfce-desktop as it sucks in wicd but
	# migrating user is used to network-manager and this will spoil his experience.
	apt install task-xfce-desktop --no-install-recommends -y
fi

if test $KDE -eq 1 ; then
	echo "Installing task-kde-desktop"
	apt install task-kde-desktop --no-install-recommends -y > /dev/null 2>&1
	echo "* Select slim as Display manager when prompted!                               *"
	echo "* Hit Enter to continue                                                       *"
	read -r DUMMY
	echo "Installing slim DM"
	apt install slim -yq
	# PARANOIA
	systemctl disable sddm
	#systemctl disable slim

fi

if test $MATE -eq 1 ; then
	# Don't install recommends for task-mate-desktop as it sucks in wicd but
	# migrating user is used to network-manager and this will spoil his experience.
	apt install task-mate-desktop --no-install-recommends -y
fi

if test $CINNAMON -eq 1 ; then
	apt install task-cinnamon-desktop -y
fi

# WARNING you should do this migration by hand
# if you are not sitting in the same room of the server
if test $SERVER -eq 1 ; then
	dpkg -L task-print-server > /dev/null 2>&1
	if test $? -eq 0 ; then
		echo "Installing task-print-server"
		apt install task-print-server -y
	fi
	dpkg -L task-ssh-server > /dev/null 2>&1
	if test $? -eq 0 ; then
		echo "Installing task-ssh-server"
		apt install task-ssh-server -y
	fi
	dpkg -L task-web-server > /dev/null 2>&1
	if test $? -eq 0 ; then
		echo "Installing task-web-server"
		apt install task-web-server -y
	fi
fi

# DOWNLOAD PACKAGES FOR LATER USE
DOWNLOAD_LIST="\
util-linux \
libelogind0 \
libpam-elogind \
elogind \
init \
sysvinit-core \
initscripts \
sysv-rc \
insserv \
startpar \
eudev \
libeudev1"

if test $INSTALL_DBUS -eq 1 ; then
	DOWNLOAD_LIST="$DOWNLOAD_LIST dbus  dbus-x11 libdbus-1-3"
fi

if test $INSTALL_NM -eq 1 ; then
	DOWNLOAD_LIST="$DOWNLOAD_LIST network-manager libnm0"
fi

if test $INSTALL_NM_GNOME -eq 1 ; then
	DOWNLOAD_LIST="$DOWNLOAD_LIST network-manager-gnome"
fi

if test $INSTALL_NM_KDE -eq 1 ; then
	DOWNLOAD_LIST="$DOWNLOAD_LIST plasma-nm"
fi

if test $INSTALL_DEBIAN_PULSEAUDIO_CONFIG_OVERRIDE -eq 1 ; then
	DOWNLOAD_LIST="$DOWNLOAD_LIST debian-pulseaudio-config-override"
fi

for DEB in $DOWNLOAD_LIST
do
	apt-get download "$DEB" > /dev/null 2>&1
	if test $? -ne 0 ; then
		echo "Downloading $DEB...failed, exiting..."
		exit 1
	fi
	echo "Downloading $DEB...done"
done

# INSTALL DEVUAN NETWORK-MANAGER
# or set it to manually installed so that it will not be autoremoved later.
# ORDER MATTERS!
if test $INSTALL_NM_GNOME -eq 1 ; then
	echo "Installing network-manager-gnome" 
	dpkg -i --force-all ./network-manager-gnome*.deb > /dev/null 2>&1
fi
if test $INSTALL_NM_KDE -eq 1 ; then
	echo "Installing plasma-nm" 
	dpkg -i --force-all ./plasma-nm*.deb > /dev/null 2>&1
fi
if test $INSTALL_NM -eq 1 ; then
	echo "Installing libnm0" 
	dpkg -i --force-all ./libnm0*.deb > /dev/null 2>&1 
		echo "Installing network-manager"
	dpkg -i --force-all ./network-manager_*.deb > /dev/null 2>&1
fi

# REMOVE SOME SYSTEMD RELATED PACKAGES THAT GET IN THE WAY
# Don't remove fonts-quicksand ,breaks desktop-base
REMOVE_LIST="\
dbus-user-session \
$IIO_SENSORS_PROXY \
libnss-systemd \
libpam-systemd \
plymouth-label \
plymouth \
$LIBPLYMOUTH \
udev \
libudev1 \
$SYSTEMD_TIMESYNCD"
# TODO install an alternative NTP client?

for DEB in $REMOVE_LIST
do
	echo "Removing $DEB"
	dpkg --purge --force-all "$DEB" > /dev/null 2>&1
done

# DETECT LIBSYSTEMD AND SAVE A COPY TO KEEP APT and SYSTEMCTL HAPPY
LIBSYSTEMD=$(dpkg -L libsystemd0 | grep ".so.0.")
echo "Saving a copy of '$LIBSYSTEMD'" 
cp "$LIBSYSTEMD" "$LIBSYSTEMD".bak


# BEGIN TO REMOVE SYSTEMD
echo "Removing systemd-sysv"
dpkg --purge --force-all systemd-sysv > /dev/null 2>&1
# Don't remove it here we need it to reboot the box
#dpkg --purge --force-all systemd
echo "Removing libsystemd0"
dpkg --purge --force-all libsystemd0 > /dev/null 2>&1
# RESTORE LIBSYSTEMD
cp "$LIBSYSTEMD".bak "$LIBSYSTEMD"

# ORDER MATTERS!
DEVUAN_LIST="\
libeudev1 \
util-linux \
libelogind0 \
elogind \
libpam-elogind \
eudev \
insserv \
startpar \
sysv-rc \
initscripts \
sysvinit-core \
init"

if test $INSTALL_DBUS -eq 1 ; then
	DEVUAN_LIST="$DEVUAN_LIST dbus dbus-x11 libdbus"
fi

if test $INSTALL_DEBIAN_PULSEAUDIO_CONFIG_OVERRIDE -eq 1 ; then
	DEVUAN_LIST="$DEVUAN_LIST debian-pulseaudio-config-override"
fi

# FORCE INSTALL DEVUAN PACKAGES TO BE SURE
for DEBNAME in $DEVUAN_LIST
do
	echo "Installing $DEBNAME"
	dpkg -i --force-all ./"$DEBNAME"*.deb > /dev/null 2>&1
done

# CLEANUP
CLEANUP_LIST="$DEVUAN_LIST"
if test $INSTALL_NM_GNOME -eq 1 ; then
	CLEANUP_LIST="$CLEANUP_LIST network-manager-gnome"
fi
if test $INSTALL_NM_GNOME -eq 1 ; then
	CLEANUP_LIST="$CLEANUP_LIST plasma-nm"
fi
if test $INSTALL_NM -eq 1 ; then
	CLEANUP_LIST="$CLEANUP_LIST libnm0 network-manager_"
fi

for DEBNAME in $CLEANUP_LIST
do
	echo "Deleting downloaded package: $DEBNAME"
	rm -f "$DEBNAME"*.deb
done

# CHECK FOR INITTAB AND INSTALL IF MISSING
if test -f /etc/inittab ; then
	echo "Checking for existence of /etc/inittab: found"
else
	echo "Checking for existence of /etc/inittab: not found"
	echo "Copying /usr/share/sysvinit/inittab to /etc/inittab"
	cp /usr/share/sysvinit/inittab /etc/inittab
fi

# INSTRUCTIONS FOR STAGE 2
INFOTMP=$(mktemp Info-XXXXXXXX.txt)
{ echo "********************************************************************************"; \
echo "*  After reboot remove references to debian $VERSION_CODENAME from /etc/apt/sources.list$PAD*" ; \
echo "*  and run the stage 2 script in a root shell:                                 *" ; \
echo "$PWD/migration-stage2.sh" ; \
if test $LXQT -eq 1 -o $LXDE -eq 1 -o $SERVER -eq 1 ; then
	echo "*  Reconfigure your /etc/network/interfaces file to use old-fashion network    *" ; \
	echo "*  names e.g. eth0 or wlan0 (or add net.ifnames=1 to grub command line),       *" ; \
	echo "*  you will be prompted to do it now if you like.                              *" ; \
fi
if test $LXQT -eq 1; then
	echo "*  and also check your connman-ui preferences                                  *" ; \
fi
if test "x$VERSION_ID" = "x11" -a $LXDE -eq 1 ; then
	echo "*  and also check your connman-ui preferences                                  *" ; \
elif test "x$VERSION_ID" = "x10" -a $LXDE -eq 1 ; then
	echo "*  and also check and reconfigure your wicd preferences                        *" ; \
fi
echo "********************************************************************************" ; } | tee "$PWD/$INFOTMP"
echo "You can find these instructions in the file: $PWD/$INFOTMP"

{ echo "#!/bin/sh"; \
echo "echo \"Setting PATH=$PATH:/usr/sbin:/sbin\""; \
echo "export PATH=\$PATH:/usr/sbin:/sbin"; \
echo "echo \"Removing saved copy of $LIBSYSTEMD\"" ; \
echo "rm -f $LIBSYSTEMD"; \
echo "dpkg --purge --force-all systemd"; \
echo "apt install --reinstall elogind"; \
echo "echo \"Setting date and time with ntpdate-debian\""; \
echo "ntpdate-debian pool.ntp.org"; \
echo "sleep 5"; \
echo "apt update"; \
# TODO add -y here?
echo "apt upgrade"; \
echo "apt dist-upgrade"; \
# Don't run apt autoremove --purge or we risk deleting some conf files
# from packages we erroneously removed 
echo "apt autoremove"; \
echo "apt remove ntpdate"; \
echo "echo \"Hit Enter to reboot\""; \
echo "read -r DUMMY"; \
echo "reboot"; } > "$PWD"/migration-stage2.sh

chmod 766 "$PWD/migration-stage2.sh"
# Same ownership as current running script
chown --reference="$0" "$PWD/migration-stage2.sh"
chmod 666 "$PWD/$INFOTMP"

if test $LXQT -eq 1 -o $LXDE -eq 1 -o $SERVER -eq 1 ; then
	# WAIT FOR USER TO READ
	echo "Hit Enter to continue"
	read -r DUMMY

	echo "Do you want to edit /etc/network/interfaces now? [y|n]"
	read -r ANS
	if test "x$ANS" = "xy" -o "x$ANS" = "xY"; then
		cp /etc/network/interfaces /etc/network/interfaces.bak
		nano /etc/network/interfaces
	fi
fi

# DONE
echo "You can reboot now" 

# CLEANUP
rm -f /etc/apt/preferences.d/"$DEVUAN_CODENAME"
