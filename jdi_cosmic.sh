#!/bin/bash
# JDInstall

CODENAME="cosmic"
RELEASE="18.10"
VERSION="JDInstall $CODENAME"
PINGSITE="www.google.com"

APP_OFFICIAL_REPOS="alacarte android-sdk-platform-tools-common autofs build-essential bwm-ng calibre chrome-gnome-shell cmatrix compizconfig-settings-manager curl default-jdk dkms exfat-fuse exfat-utils faenza-icon-theme filezilla finch flashplugin-installer gconf-service gconf-service-backend gconf2-common gdebi gimp gir1.2-clutter-1.0 gir1.2-clutter-gst-3.0 gir1.2-gtkclutter-1.0 gir1.2-gtop-2.0 gir1.2-networkmanager-1.0 git gnome-backgrounds gnome-commander gnome-gmail gnome-system-tools gnome-themes-standard gnome-tweak-tool gparted grsync gthumb gtk-recordmydesktop gwakeonlan hardinfo hddtemp htop icedtea-plugin inkscape inxi iotop jstest-gtk k3b libgconf-2-4 libreoffice libsoil1 lm-sensors linux-headers-generic mc meld mercurial mplayer mumble nautilus-dropbox nautilus-image-converter ncdu nfs-common nfs-kernel-server openjdk-8-jdk p7zip p7zip-full p7zip-rar pidgin powertop pavucontrol ppa-purge python-pip python-dev pwgen rar saidar silversearcher-ag sloccount smartmontools soundconverter sox subtitleeditor subversion synaptic synapse tig tofrodos tree ttf-mscorefonts-installer ubuntu-restricted-extras unshield vdpau-va-driver vim vim-gtk vlc xclip wakeonlan zlib1g-dev" #g15daemon tvtime me-tv eclipse texmaker texlive" #myunity ffmpeg synapse

APP_OTHER_REPOS="libdvdcss2 google-chrome-beta" # google-musicmanager-beta google-talkplugin jdownloader


#if [[ `uname -m` == 'amd64' || `uname -m` == 'x86_64' ]]
#then
	#APP_OTHER_REPOS=$APP_OTHER_REPOS" g++-multilib"	
#fi

APPZ="$APP_OFFICIAL_REPOS $APP_OTHER_REPOS"

AUTOYES="--assume-yes"

while getopts :lhvy PARAMETER
do
	case $PARAMETER in
		l)
		echo "List of the packages to install:"
		echo $APPZ
		exit 0
		;;
		h)
		echo "Uso: $0 [PARAMETER]"
		echo "If no parameter is specified, the script start the installation"
		echo "   -l		List of the packages to install"
		echo "   -h		Show this help text"
		echo "   -v		Show the version"
		echo ""
		echo "Issue tracker: https://github.com/leinardi/JDInstaller/issues"
		exit 0
		;;	
		v)
		echo $VERSION
		exit 0
		;;
		*)
		echo "Invalid parameter."
		echo ""
		$0 -h
		exit 1
		;;
	esac
done

lsb_release -c | grep -q $CODENAME 
if [[ $? -ne 0 ]]
then
	echo "This script can be used only with Ubuntu $RELEASE ($CODENAME)"
	echo ""
	echo "Distribution-specific information of your current installation:"
	lsb_release -d -c
	exit 1
fi


if [[ $EUID -ne 0 ]]
then
	echo "This script require root permission." 1>&2
	chmod 755 ./`basename $0`
	sudo ./`basename $0`
	exit 0
fi

echo "tempd dir -> $tmp_dir"

clean_up () 
{
  echo "Cleaning up"
  rm -rf $tmp_dir
  exit 0
}

trap clean_up SIGKILL SIGINT SIGTERM

function add_repo {
echo -n "Repository $1: "
if cat /etc/apt/sources.list /etc/apt/sources.list.d/*.list | grep -q "$2"
then
	echo "Already added"
else
	echo "$2" >> /etc/apt/sources.list.d/$1.list
	#	echo "$2 #$1" >> /etc/apt/sources.list
	chmod 644 /etc/apt/sources.list.d/$1.list
	echo "Added"
	if [[ $# -gt 2 ]]
	then
		echo -n "Adding trusted key for $1: "
		wget -q -O - $3 | apt-key add -
		sleep 2
	fi
fi
}

function enable_repo {
if cat /etc/apt/sources.list | grep -q "# $2"
then
	echo -n "Enabling repository $1: "
	if eval $3
	then
		echo "OK"
	else
		echo "FAIL!"
	fi
else
	echo -n "Repository $1: "
	if cat /etc/apt/sources.list | grep -q "$2"
	then
		echo "Already enabled"
	else
		echo "$2 #$1" >> /etc/apt/sources.list
		echo "Enabled"
	fi
fi

}

PARTNER="deb http://archive.canonical.com/ubuntu $CODENAME partner"
PARTNER_SRC="deb-src http://archive.canonical.com/ubuntu $CODENAME partner"
PARTNER_SED='sed -i -e "s/# deb http:\/\/archive.canonical.com\/ubuntu '$CODENAME' partner/deb http:\/\/archive.canonical.com\/ubuntu '$CODENAME' partner/g" /etc/apt/sources.list'
PARTNER_SRC_SED='sed -i -e "s/# deb-src http:\/\/archive.canonical.com\/ubuntu '$CODENAME' partner/deb-src http:\/\/archive.canonical.com\/ubuntu '$CODENAME' partner/g" /etc/apt/sources.list'

BACKPORTS="deb http://it.archive.ubuntu.com/ubuntu/ $CODENAME-backports main restricted universe multiverse"
BACKPORTS_SRC="deb-src http://it.archive.ubuntu.com/ubuntu/ $CODENAME-backports main restricted universe multiverse"
BACKPORTS_SED='sed -i -e "s/# deb http:\/\/it.archive.ubuntu.com\/ubuntu\/ '$CODENAME'-backports main restricted universe multiverse/deb http:\/\/it.archive.ubuntu.com\/ubuntu\/ '$CODENAME'-backports main restricted universe multiverse/g" /etc/apt/sources.list'
BACKPORTS_SRC_SED='sed -i -e "s/# deb-src http:\/\/it.archive.ubuntu.com\/ubuntu\/ '$CODENAME'-backports main restricted universe multiverse/deb-src http:\/\/it.archive.ubuntu.com\/ubuntu\/ '$CODENAME'-backports main restricted universe multiverse/g" /etc/apt/sources.list'


VIDEOLAN="deb http://download.videolan.org/pub/debian/stable/ /"
VIDEOLAN_KEY="http://download.videolan.org/pub/debian/videolan-apt.asc"
SKYPE="deb http://download.skype.com/linux/repos/debian stable non-free"
DROPBOX="deb http://linux.dropbox.com/ubuntu $CODENAME main"
DROPBOX_SRC="deb-src http://linux.dropbox.com/ubuntu $CODENAME main"
VIRTUALBOX="deb http://download.virtualbox.org/virtualbox/debian $CODENAME contrib"
VIRTUALBOX_KEY="http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc"
#VBOX_USB="none /proc/bus/usb usbfs devgid=125,devmode=664 0 0"
GOOGLE_CHROME="deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"
GOOGLE_MUSIC_MANAGER="deb http://dl.google.com/linux/musicmanager/deb/ stable main"
GOOGLE_TALKPLUGIN="deb http://dl.google.com/linux/talkplugin/deb/ stable main"
GOOGLE_KEY="https://dl-ssl.google.com/linux/linux_signing_key.pub"
GETDEB="deb http://archive.getdeb.net/ubuntu $CODENAME-getdeb apps"
GETDEB_KEY="http://archive.getdeb.net/getdeb-archive.key"

echo "List of packages to be installed:"
echo "$APPZ"
echo
read -p "Continuae [Y/n]? " yn

if [[ $yn != 'y' ]] && [[ $yn != 'Y' ]] && [[ $yn != '' ]]
then
	echo "Installation canceled"
	exit 1
fi

echo
echo -n "Checking internet connection: "
ping -c1 $PINGSITE > /dev/null
if [ "$?" -ne 0 ] 
then
	echo "FAIL"
	echo "Unable to ping $PINGSITE."
	echo "Check your internet connection and try again."
	exit 1
fi
echo "OK"

echo
echo "=== Updating package indexes ==="
echo
sleep 1
apt-get update
echo
echo "=== Updating installed packages ==="
echo
sleep 1
apt-get upgrade $AUTOYES

echo
echo "=== Adding repositories ==="
sleep 1

echo -n "Backup original source.list: "
if cp /etc/apt/sources.list /etc/apt/sources.list.`date +%Y%m%d-%H%M%S`
then
	echo "OK"
fi
echo

enable_repo "Ubuntu Partner" "$PARTNER" "$PARTNER_SED"
enable_repo "Ubuntu Partner (Sources)" "$PARTNER_SRC" "$PARTNER_SRC_SED"
enable_repo "Ubuntu $CODENAME-Backports" "$BACKPORTS" "$BACKPORTS_SED"
enable_repo "Ubuntu $CODENAME-Backports (Sources)" "$BACKPORTS_SRC" "$BACKPORTS_SRC_SED"

#add-apt-repository -y ppa:tualatrix/ppa #Ubuntu-Tweak
#add-apt-repository -y ppa:jd-team/jdownloader #JDownloader
#add-apt-repository -y ppa:tiheum/equinox #Faenza
add-apt-repository -y ppa:graphics-drivers/ppa #Proprietary GPU Drivers
#add-apt-repository -y ppa:berfenger/roccat
#add-apt-repository -y ppa:mumble/release #Mumble
#add-apt-repository -y ppa:uck-team/uck-stable #UCK
#add-apt-repository -y ppa:subdownloader-developers/ppa #SubDownloader
#add-apt-repository -y ppa:pkg-games/ppa #pkg-games
#add-apt-repository -y ppa:atareao/atareao
add_repo "google-chrome-beta" "$GOOGLE_CHROME" "$GOOGLE_KEY"
#add_repo "google-musicmanager" "$GOOGLE_MUSIC_MANAGER" "$GOOGLE_KEY"
#add_repo "google-talkplugin" "$GOOGLE_TALKPLUGIN" "$GOOGLE_KEY"
#add_repo "videolan" "$VIDEOLAN" "$VIDEOLAN_KEY"
#add_repo "virtualbox" "$VIRTUALBOX" "$VIRTUALBOX_KEY"
#add_repo "dropbox" "$DROPBOX"
#add_repo "getdeb" "$GETDEB" "$GETDEB_KEY"
#add_repo "skype" "$SKYPE"

echo "=== Repositories added ==="
echo

sleep 2

echo
echo "=== Updating package indexes ==="
echo
sleep 1
apt-get update
echo
echo "=== Updating installed packages ==="
echo
sleep 1
apt-get upgrade $AUTOYES
echo
echo "=== Installing new packages ==="
echo
sleep 1
apt-get install $AUTOYES $APPZ
apt-get remove $AUTOYES postfix indicator-appmenu
#pip install Glances

if [[ `uname -m` == 'amd64' || `uname -m` == 'x86_64' ]]
then
	echo "=== Installing Skype ==="
	wget -O $tmp_dir/skype.deb https://go.skype.com/skypeforlinux-64.deb &&
	apt install $tmp_dir/skype.deb
fi

apt $AUTOYES --fix-broken install

echo
echo "=== Cleanup Unity indicators ==="
echo
#apt $AUTOYES purge indicator-application indicator-appmenu indicator-bluetooth indicator-common indicator-datetime indicator-keyboard indicator-messages  indicator-power indicator-printers indicator-session indicator-sound

# disabling mouse acceleration
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'

# ubuntu-dock preferences
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'cycle-windows'
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true

# gnome preferences
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Primary><Alt><Super>space']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Primary><Shift><Alt><Super>space']"
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.interface menus-have-icons true
gsettings set org.gnome.desktop.interface buttons-have-icons true

# gedit preferences
gsettings set org.gnome.gedit.preferences.editor bracket-matching true
gsettings set org.gnome.gedit.preferences.editor display-line-numbers true
gsettings set org.gnome.gedit.preferences.editor highlight-current-line true

# nautilus
gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'

clean_up

exit 0
