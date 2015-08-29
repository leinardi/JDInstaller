#!/bin/bash
# JDInstall
# TODO:
# *) Scrivere una breve descrizione del programma al posto del commento #JDInstall
# *) Installazione selettiva dei repository esterni e delle applicazioni a essi legate
# *) Prevedere un "dpkg --config -a" in caso di problemi
#
#
DISTRIBUZIONE="vivid"
VERSIONE="JDInstall 1.1404.0 ($DISTRIBUZIONE)"

APPZ_REPO_UFFICIALI="alacarte autofs build-essential bwm-ng calibre cmatrix compizconfig-settings-manager conky-all curl dconf-tools default-jdk dkms exfat-fuse exfat-utils filezilla finch flashplugin-installer gdebi gimp git gnome-backgrounds gnome-commander gnome-gmail gnome-mplayer gnome-search-tool gnome-system-tools gnome-themes-standard gnome-tweak-tool gparted gthumb gtk-recordmydesktop gwakeonlan hardinfo hddtemp htop icedtea-plugin indicator-multiload inkscape inxi iotop jstest-gtk k3b libreoffice libsoil1 lm-sensors linux-headers-generic mc meld mercurial mplayer mumble nautilus-actions nautilus-dropbox nautilus-image-converter nautilus-open-terminal nfs-common nfs-kernel-server openjdk-7-jdk p7zip p7zip-full p7zip-rar pidgin powertop pavucontrol ppa-purge python-pip python-dev pwgen rar saidar silversearcher-ag sloccount skype smartmontools soundconverter sox subtitleeditor subversion synaptic tagtool tofrodos tree ttf-mscorefonts-installer ubuntu-restricted-extras unity-tweak-tool unshield vdpau-va-driver vim vim-gtk vlc vlc-plugin-pulse wakeonlan zlib1g-dev" #g15daemon tvtime me-tv eclipse texmaker texlive" #myunity ffmpeg synapse

APPZ_ALTRI_REPO="libdvdcss2 google-chrome-beta google-musicmanager-beta google-talkplugin" # indicator-sensors jdownloader  my-weather-indicator 

APPZ_DIPENDENZE_ECLIPSE="ant ant-optional aspectj binfmt-support fastjar jarwrapper junit junit4 sat4j x11proto-core-dev x11proto-input-dev x11proto-kb-dev xorg-sgml-doctools xtrans-dev"

APPZ_DIPENDENZE_QT="mesa-common-dev libgl1-mesa-dev libglu1-mesa-dev"

if [[ `uname -m` == 'amd64' || `uname -m` == 'x86_64' ]]
then
	APPZ_DIPENDENZE_QT=$APPZ_DIPENDENZE_QT" g++-multilib"
	
fi

APPZ="$APPZ_REPO_UFFICIALI $APPZ_ALTRI_REPO $APPZ_DIPENDENZE_ECLIPSE $APPZ_DIPENDENZE_QT"

AUTOYES="--assume-yes"

case $TMPDIR in 
	'')
		tmp_dir="/tmp"
		;; 

	*)
		tmp_dir=$TMPDIR
		;;
esac

while getopts :ahvy OPZIONE
do
	case $OPZIONE in
		a)
		echo "Elenco dei pacchetti da installare:"
		echo $APPZ
		exit 0
		;;
		h)
		echo "Uso: $0 [OPZIONE]"
		echo "Se avviato senza opzioni lo script procede con l'installazione."
		echo "   -a		Visualizza l'elenco dei pacchetti da installare"
		echo "   -h		Mostra questo aiuto"
		echo "   -v		Visualizza il numero di versione"
		echo ""
		echo "Segnalare i bug a <webmaster@jdsblog.it>."
		echo "Maggiori info su http://www.jdsblog.it/jdinstaller/"
		exit 0
		;;	
		v)
		echo $VERSIONE
		exit 0
		;;
		y)
		$AUTOYES="--yes" #--force-yes"
		;;
		*)
		echo "È stata indicata un'opzione illegale."
		echo "Utilizzare $0 -h per ulteriori informazioni."
		exit 1
		;;
	esac
done

lsb_release -c | grep -q $DISTRIBUZIONE 
if [[ $? -ne 0 ]]
then
	echo "Questo script è utilizzabile esclusivamente su Ubuntu 14.04 ($DISTRIBUZIONE)"
	echo "Info sulla tua distribuzione:"
	lsb_release -d -c
	exit 1
fi


if [[ $EUID -ne 0 ]]
then
	echo "Lo script richiede l'esecuzione con i permessi di root." 1>&2
	chmod 755 ./`basename $0`
	sudo ./`basename $0`
	exit 0
fi

function add_repo {
echo -n "Repository di $1: "
if cat /etc/apt/sources.list /etc/apt/sources.list.d/*.list | grep -q "$2"
then
	echo "Già presente"
else
	echo "$2" >> /etc/apt/sources.list.d/$1.list
	#	echo "$2 #$1" >> /etc/apt/sources.list
	chmod 644 /etc/apt/sources.list.d/$1.list
	echo "Aggiunto"
	if [[ $# -gt 2 ]]
	then
		echo -n "Importazione chiave di $1: "
		 wget -q -O - $3 | apt-key add -
		sleep 2
	fi
fi
}

function enable_repo {
echo "poba = $3"
if cat /etc/apt/sources.list | grep -q "# $2"
then
	echo -n "Abilitazione Repository $1: "
	if eval $3
	then
		echo "OK"
	else
		echo "FALLITA!"
	fi
else
	echo -n "Repository $1: "
	if cat /etc/apt/sources.list | grep -q "$2"
	then
		echo "Già presente"
	else
		echo "$2 #$1" >> /etc/apt/sources.list
		echo "Aggiunto"
	fi
fi

}


REPOLIST="JDownloader, Synapse, Faenza, X-Updates, Google Chrome, Google Talk"

PINGSITE="www.google.com"

PARTNER="deb http://archive.canonical.com/ubuntu $DISTRIBUZIONE partner"
PARTNER_SRC="deb-src http://archive.canonical.com/ubuntu $DISTRIBUZIONE partner"
PARTNER_SED='sed -i -e "s/# deb http:\/\/archive.canonical.com\/ubuntu '$DISTRIBUZIONE' partner/deb http:\/\/archive.canonical.com\/ubuntu '$DISTRIBUZIONE' partner/g" /etc/apt/sources.list'
PARTNER_SRC_SED='sed -i -e "s/# deb-src http:\/\/archive.canonical.com\/ubuntu '$DISTRIBUZIONE' partner/deb-src http:\/\/archive.canonical.com\/ubuntu '$DISTRIBUZIONE' partner/g" /etc/apt/sources.list'

BACKPORTS="deb http://it.archive.ubuntu.com/ubuntu/ $DISTRIBUZIONE-backports main restricted universe multiverse"
BACKPORTS_SRC="deb-src http://it.archive.ubuntu.com/ubuntu/ $DISTRIBUZIONE-backports main restricted universe multiverse"
BACKPORTS_SED='sed -i -e "s/# deb http:\/\/it.archive.ubuntu.com\/ubuntu\/ '$DISTRIBUZIONE'-backports main restricted universe multiverse/deb http:\/\/it.archive.ubuntu.com\/ubuntu\/ '$DISTRIBUZIONE'-backports main restricted universe multiverse/g" /etc/apt/sources.list'
BACKPORTS_SRC_SED='sed -i -e "s/# deb-src http:\/\/it.archive.ubuntu.com\/ubuntu\/ '$DISTRIBUZIONE'-backports main restricted universe multiverse/deb-src http:\/\/it.archive.ubuntu.com\/ubuntu\/ '$DISTRIBUZIONE'-backports main restricted universe multiverse/g" /etc/apt/sources.list'


VIDEOLAN="deb http://download.videolan.org/pub/debian/stable/ /"
VIDEOLAN_KEY="http://download.videolan.org/pub/debian/videolan-apt.asc"
SKYPE="deb http://download.skype.com/linux/repos/debian stable non-free"
DROPBOX="deb http://linux.dropbox.com/ubuntu $DISTRIBUZIONE main"
DROPBOX_SRC="deb-src http://linux.dropbox.com/ubuntu $DISTRIBUZIONE main"
VIRTUALBOX="deb http://download.virtualbox.org/virtualbox/debian $DISTRIBUZIONE contrib"
VIRTUALBOX_KEY="http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc"
#VBOX_USB="none /proc/bus/usb usbfs devgid=125,devmode=664 0 0"
GOOGLE_CHROME="deb http://dl.google.com/linux/chrome/deb/ stable main"
GOOGLE_MUSIC_MANAGER="deb http://dl.google.com/linux/musicmanager/deb/ stable main"
GOOGLE_TALKPLUGIN="deb http://dl.google.com/linux/talkplugin/deb/ stable main"
GOOGLE_KEY="https://dl-ssl.google.com/linux/linux_signing_key.pub"
GETDEB="deb http://archive.getdeb.net/ubuntu $DISTRIBUZIONE-getdeb apps"
GETDEB_KEY="http://archive.getdeb.net/getdeb-archive.key"

echo "Questo script aggiungerà al source.list i seguenti repository per Ubuntu 12.04:"
echo "$REPOLIST"
echo
echo "Provvederà poi ad installare i seguenti pacchetti:"
echo "$APPZ"
echo
read -p "Continuare [S/n]? " sn

if [[ $sn != 's' ]] && [[ $sn != 'S' ]] && [[ $sn != '' ]]
then
	echo "Interrotto."
	exit 1
fi

echo
echo -n "Verifica connessione ad internet: "
ping -c1 $PINGSITE > /dev/null
if [ "$?" -ne 0 ] 
then
	echo "FALLITA"
	echo "Il ping di $PINGSITE non è riuscito."
	echo "Controllare la connessione ad internet e riprovare"
	exit 1
fi
echo "OK"

echo
echo "=== Aggiornamento sorgenti software ==="
echo
sleep 1
apt-get update
echo
echo "=== Aggiornamento pacchetti installati ==="
echo
sleep 1
apt-get upgrade $AUTOYES

echo
echo "=== Aggiunta repository ==="
sleep 1

echo -n "Backup del source.list originare: "
if cp /etc/apt/sources.list /etc/apt/sources.list.`date +%Y%m%d-%H%M%S`
then
	echo "OK"
fi
echo

enable_repo "Ubuntu Partner" "$PARTNER" "$PARTNER_SED"
enable_repo "Ubuntu Partner (Sorgenti)" "$PARTNER_SRC" "$PARTNER_SRC_SED"
enable_repo "Ubuntu $DISTRIBUZIONE-Backports" "$BACKPORTS" "$BACKPORTS_SED"
enable_repo "Ubuntu $DISTRIBUZIONE-Backports (Sorgenti)" "$BACKPORTS_SRC" "$BACKPORTS_SRC_SED"

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
add_repo "google-musicmanager" "$GOOGLE_MUSIC_MANAGER" "$GOOGLE_KEY"
add_repo "google-talkplugin" "$GOOGLE_TALKPLUGIN" "$GOOGLE_KEY"
add_repo "videolan" "$VIDEOLAN" "$VIDEOLAN_KEY"
#add_repo "virtualbox" "$VIRTUALBOX" "$VIRTUALBOX_KEY"
#add_repo "dropbox" "$DROPBOX"
#add_repo "getdeb" "$GETDEB" "$GETDEB_KEY"
#add_repo "skype" "$SKYPE"

echo "=== Repository aggiunti ==="
echo

sleep 2

echo "L'esecuzione proseguirà con l'installazione dei seguenti paccehtti:"
echo "$APPZ"
echo
read -p "Continuare [S/n]? " sn

if [[ $sn != 's' ]] && [[ $sn != 'S' ]] && [[ $sn != '' ]]
then
	echo "Interrotto."
	exit 1
fi

echo
echo "=== Aggiornamento sorgenti software ==="
echo
sleep 1
apt-get update
echo
echo "=== Aggiornamento pacchetti installati ==="
echo
sleep 1
apt-get upgrade $AUTOYES
echo
echo "=== Installazione pacchetti ==="
echo
sleep 1
apt-get install $AUTOYES $APPZ
apt-get remove $AUTOYES postfix indicator-appmenu
pip install Glances
pip install PySensors

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
