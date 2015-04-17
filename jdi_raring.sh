#!/bin/bash
# JDInstall
# TODO:
# *) Scrivere una breve descrizione del programma al posto del commento #JDInstall
# *) Installazione selettiva dei repository esterni e delle applicazioni a essi legate
# *) Prevedere un "dpkg --config -a" in caso di problemi
#
# Changelog:
#
# Versione 1.0910.3 (1 dic 2009)
# * Separazione tra applicazioni presenti o meno nei repo ufficiali di Ubuntu
# * Ordinamento alfabetico dei pacchetti
# * Sostituito Kompare con Meld
# * Sostituito GFTP con Filezilla
# * Aggiunto il repository di GetDeb
#
# Versione 1.0910.2 (7 nov 2009)
# * Abilitati i repository di Dropbox e VirtualBox
# * Aggiunto pwgen all'elenco dei pacchetti
# * Aggiunto Sun Java6 Plugin all'elenco dei pacchetti (abilita il supporto alle applet Java in Firefox)
# 
# Versione 1.0910.1 (2 ott 2009)
# * Script aggiornato per Ubuntu 9.10 Lucid Linx
# * Aggiunto Audio Tag Tool all'elenco dei pacchetti
# * Aggiunto Sound Converter all'elenco dei pacchetti
# * Aggiunto Pidgin all'elenco dei pacchetti
# * Aggiunto GThumb all'elenco dei pacchetti
# * Aggiornato lo script per l'utilizzo di add-apt-repository
#
# Versione 1.0.1 (27 lug 2009)
# * Aggiunto il Changelog
# * Aggiunta la variabile DISTRIBUZIONE
# * Aggiunto la variabile VERSIONE
# * Aggiuntoil parsing degli argomenti
# * Aggiunte le opzioni -a -h -v
# * Aggiunto supporto sperimentale ad architettura x86_64
#
DISTRIBUZIONE="raring"
VERSIONE="JDInstall 1.0910.3 ($DISTRIBUZIONE)"

WXXCODECS="w32codecs"
if [[ `uname -m` == 'amd64' || `uname -m` == 'x86_64' ]]
then
	WXXCODECS="w64codecs"
	echo "ATTENZIONE: Supporto ad architettura x86_64 sperimentale."
	echo "In caso di problemi inviare segnalazioni a <webmaster@jdsblog.it>"
	echo "o visitare http://www.jdsblog.it/jdinstaller/"
	read -p "Premere un tasto per continuare..."
fi


APPZ_REPO_UFFICIALI="build-essential bwm-ng cmatrix compizconfig-settings-manager conky dkms ffmpeg filezilla finch gdebi gimp git gnome-backgrounds gnome-commander gnome-mplayer gnome-search-tool gnome-session-fallback gnome-system-tools gnome-themes-standard gnome-tweak-tool gparted gthumb gtk-recordmydesktop hardinfo hddtemp htop icedtea-plugin inkscape iotop k3b libreoffice lm-sensors linux-headers-generic mc meld mercurial mplayer mumble nautilus-actions nautilus-dropbox nautilus-image-converter nautilus-open-terminal nfs-common nfs-kernel-server p7zip p7zip-full p7zip-rar pidgin powertop pwgen rar sloccount skype smartmontools soundconverter sox subtitleeditor subversion synapse synaptic tagtool tofrodos tree ttf-mscorefonts-installer ubuntu-restricted-extras unity-tweak-tool vdpau-va-driver vim vim-gtk vlc vlc-plugin-pulse zlib1g-dev" #g15daemon tvtime me-tv eclipse texmaker texlive" #myunity

APPZ_ALTRI_REPO="$WXXCODECS faenza-icon-theme libdvdcss2 jdownloader indicator-multiload my-weather-indicator google-chrome-unstable google-musicmanager-beta google-talkplugin" # indicator-sensors

APPZ_DIPENDENZE_ECLIPSE="ant ant-optional default-jdk fastjar gcj-4.6-base gcj-4.6-jre-lib jarwrapper junit junit4 libapache-pom-java libasm3-java libcommons-beanutils-java libcommons-cli-java libcommons-codec-java libcommons-collections3-java libcommons-compress-java libcommons-digester-java libcommons-el-java libcommons-httpclient-java libcommons-lang-java libcommons-logging-java libcommons-parent-java libdb-java libdb-je-java libdb5.1-java libdb5.1-java-gcj libecj-java libequinox-osgi-java libgcj-bc libgcj-common libgcj12 libhamcrest-java libice-dev libicu4j-4.4-java libicu4j-java libjetty-java libjline-java libjsch-java libjtidy-java liblucene2-java libpthread-stubs0 libpthread-stubs0-dev libregexp-java libservlet2.4-java libslf4j-java libsm-dev libswt-cairo-gtk-3-jni libswt-glx-gtk-3-jni libswt-gnome-gtk-3-jni libswt-gtk-3-java libswt-gtk-3-jni libswt-webkit-gtk-3-jni libx11-dev libx11-doc libxau-dev libxcb1-dev libxdmcp-dev libxt-dev openjdk-6-jdk sat4j x11proto-core-dev x11proto-input-dev x11proto-kb-dev xorg-sgml-doctools xtrans-dev" #libjasper-java

APPZ_DIPENDENZE_QT="mesa-common-dev libgl1-mesa-dev libglu1-mesa-dev"

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
	echo "Questo script è utilizzabile esclusivamente su Ubuntu 9.10 Lucid Linx"
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


REPOLIST="Medibuntu, JDownloader, Synapse, Faenza, X-Updates, Google Chrome, Google Talk"

PINGSITE="www.google.com"

PARTNER="deb http://archive.canonical.com/ubuntu raring partner"
PARTNER_SRC="deb-src http://archive.canonical.com/ubuntu raring partner"
PARTNER_SED='sed -i -e "s/# deb http:\/\/archive.canonical.com\/ubuntu raring partner/deb http:\/\/archive.canonical.com\/ubuntu raring partner/g" /etc/apt/sources.list'
PARTNER_SRC_SED='sed -i -e "s/# deb-src http:\/\/archive.canonical.com\/ubuntu raring partner/deb-src http:\/\/archive.canonical.com\/ubuntu raring partner/g" /etc/apt/sources.list'

BACKPORTS="deb http://it.archive.ubuntu.com/ubuntu/ raring-backports main restricted universe multiverse"
BACKPORTS_SRC="deb-src http://it.archive.ubuntu.com/ubuntu/ raring-backports main restricted universe multiverse"
BACKPORTS_SED='sed -i -e "s/# deb http:\/\/it.archive.ubuntu.com\/ubuntu\/ raring-backports main restricted universe multiverse/deb http:\/\/it.archive.ubuntu.com\/ubuntu\/ raring-backports main restricted universe multiverse/g" /etc/apt/sources.list'
BACKPORTS_SRC_SED='sed -i -e "s/# deb-src http:\/\/it.archive.ubuntu.com\/ubuntu\/ raring-backports main restricted universe multiverse/deb-src http:\/\/it.archive.ubuntu.com\/ubuntu\/ raring-backports main restricted universe multiverse/g" /etc/apt/sources.list'


MEDIBUNTU="deb http://packages.medibuntu.org/ $DISTRIBUZIONE free non-free"
MEDIBUNTU_KEY="http://packages.medibuntu.org/medibuntu-key.gpg"
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
GETDEB="deb http://archive.getdeb.net/ubuntu raring-getdeb apps"
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
enable_repo "Ubuntu Raring-Backports" "$BACKPORTS" "$BACKPORTS_SED"
enable_repo "Ubuntu Raring-Backports (Sorgenti)" "$BACKPORTS_SRC" "$BACKPORTS_SRC_SED"

#add-apt-repository -y ppa:tualatrix/ppa #Ubuntu-Tweak
add-apt-repository -y ppa:jd-team/jdownloader #JDownloader
#add-apt-repository -y ppa:tortoisehg-ppa/releases #TortoiseHg
#add-apt-repository -y ppa:awn-testing/ppa #AWN Testing
#add-apt-repository -y ppa:synapse-core/ppa #Synapse
add-apt-repository -y ppa:tiheum/equinox #Faenza
#add-apt-repository -y ppa:ferramroberto/java #Java
#add-apt-repository -y ppa:n-muench/vlc #VLC
#add-apt-repository -y ppa:ubuntu-x-swat/x-updates #X-Updates
#add-apt-repository -y ppa:slicer/ppa #Mumble
#add-apt-repository -y ppa:ubuntu-desktop/ppa #Ubuntu Desktop Team
#add-apt-repository -y ppa:uck-team/uck-stable #UCK
#add-apt-repository -y ppa:subdownloader-developers/ppa #SubDownloader
#add-apt-repository -y ppa:pkg-games/ppa #pkg-games
#add-apt-repository -y ppa:deluge-team #Deluge"
add-apt-repository -y ppa:indicator-multiload/stable-daily
#add-apt-repository -y ppa:alexmurray/indicator-sensors
add-apt-repository -y ppa:atareao/atareao
add_repo "google-chrome" "$GOOGLE_CHROME" "$GOOGLE_KEY"
add_repo "google-musicmanager" "$GOOGLE_MUSIC_MANAGER" "$GOOGLE_KEY"
add_repo "google-talkplugin" "$GOOGLE_TALKPLUGIN" "$GOOGLE_KEY"
add_repo "medibuntu" "$MEDIBUNTU" "$MEDIBUNTU_KEY"
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
apt-get remove $AUTOYES postfix indicator-appmenu unity-lens-shopping 

exit 0
