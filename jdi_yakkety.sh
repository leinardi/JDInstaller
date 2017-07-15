#!/bin/bash
# JDInstall

CODENAME="yakkety"
RELEASE="16.10"
VERSION="JDInstall $CODENAME"
PINGSITE="www.google.com"

APP_OFFICIAL_REPOS="alacarte autofs build-essential bwm-ng calibre cmatrix compizconfig-settings-manager conky-all curl dconf-tools default-jdk dkms exfat-fuse exfat-utils faenza-icon-theme filezilla finch flashplugin-installer gdebi gimp git gnome-backgrounds gnome-commander gnome-gmail gnome-mplayer gnome-search-tool gnome-system-tools gnome-themes-standard gnome-tweak-tool gparted gthumb gtk-recordmydesktop gwakeonlan hardinfo hddtemp htop icedtea-plugin indicator-multiload inkscape inxi iotop jstest-gtk k3b libreoffice libsoil1 lm-sensors linux-headers-generic mc meld mercurial mplayer mumble nautilus-actions nautilus-dropbox nautilus-image-converter ncdu nfs-common nfs-kernel-server openjdk-8-jdk p7zip p7zip-full p7zip-rar pidgin powertop pavucontrol ppa-purge python-pip python-dev pwgen rar saidar silversearcher-ag sloccount skype smartmontools soundconverter sox subtitleeditor subversion synaptic synapse tagtool tig tofrodos tree ttf-mscorefonts-installer ubuntu-restricted-extras unity-tweak-tool unshield vdpau-va-driver vim vim-gtk vlc wakeonlan zlib1g-dev" #g15daemon tvtime me-tv eclipse texmaker texlive" #myunity ffmpeg synapse

APP_OTHER_REPOS="libdvdcss2 google-chrome-beta" # google-musicmanager-beta google-talkplugin indicator-sensors jdownloader  my-weather-indicator 


#if [[ `uname -m` == 'amd64' || `uname -m` == 'x86_64' ]]
#then
	#APP_OTHER_REPOS=$APP_OTHER_REPOS" g++-multilib"	
#fi

APPZ="$APP_OFFICIAL_REPOS $APP_OTHER_REPOS"

AUTOYES="--assume-yes"

case $TMPDIR in 
	'')
		tmp_dir="/tmp"
		;; 

	*)
		tmp_dir=$TMPDIR
		;;
esac

while getopts :ahvy PARAMETER
do
	case $PARAMETER in
		a)
		echo "List of the packages to install:"
		echo $APPZ
		exit 0
		;;
		h)
		echo "Uso: $0 [PARAMETER]"
		echo "If no parameter is specified, the script start the installation"
		echo "   -a		List of the packages to install"
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
GOOGLE_CHROME="deb http://dl.google.com/linux/chrome/deb/ stable main"
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
#add-apt-repository -y ppa:ubuntu-x-swat/x-updates #X-Updates
#add-apt-repository -y ppa:xorg-edgers/ppa #xorg-edgers
add-apt-repository -y ppa:graphics-drivers/ppa #Proprietary GPU Drivers
#add-apt-repository -y ppa:berfenger/roccat
#add-apt-repository -y ppa:mumble/release #Mumble
#add-apt-repository -y ppa:synapse-core/testing #Synapse Bleeding edge
#add-apt-repository -y ppa:uck-team/uck-stable #UCK
#add-apt-repository -y ppa:subdownloader-developers/ppa #SubDownloader
#add-apt-repository -y ppa:pkg-games/ppa #pkg-games
#add-apt-repository -y ppa:indicator-multiload/stable-daily
#add-apt-repository -y ppa:alexmurray/indicator-sensors
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


echo
echo "=== Disabling mouse acceleration ==="
echo
FILE="/usr/share/X11/xorg.conf.d/50-mouse-acceleration.conf"

/bin/cat <<EOM >$FILE
Section "InputClass"
	Identifier "My Mouse"
	MatchIsPointer "yes"
	Option "AccelerationProfile" "-1"
	Option "AccelerationScheme" "none"
	Option "AccelSpeed" "-1"
EndSection
EOM

# unity  preferences
gsettings set com.canonical.Unity.Lenses disabled-scopes \
      "['more_suggestions-amazon.scope', 'more_suggestions-u1ms.scope',
      'more_suggestions-populartracks.scope', 'music-musicstore.scope',
      'more_suggestions-ebay.scope', 'more_suggestions-ubuntushop.scope',
      'more_suggestions-skimlinks.scope']"
gsettings set com.canonical.unity.webapps integration-allowed false
gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ launcher-minimize-window true
gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ show-launcher '<Alt><Super>'
gsettings get org.compiz.integrated show-hud ['<Primary><Alt><Mod2>Super_L']


# indicator preferences
gsettings set com.canonical.indicator.session show-real-name-on-panel true
gsettings set com.canonical.indicator.datetime show-day true
gsettings set com.canonical.indicator.datetime show-date  true

# gnome preferences
gsettings set org.gnome.desktop.interface menus-have-icons true
gsettings set org.gnome.desktop.interface buttons-have-icons true

# gedit preferences
gsettings set org.gnome.gedit.preferences.editor bracket-matching true
gsettings set org.gnome.gedit.preferences.editor display-line-numbers true
gsettings set org.gnome.gedit.preferences.editor highlight-current-line true

# nautilus
gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'

exit 0
