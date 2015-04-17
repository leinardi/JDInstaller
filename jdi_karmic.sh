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
# * Script aggiornato per Ubuntu 9.10 Karmic Koala
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
DISTRIBUZIONE="karmic"
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


APPZ_REPO_UFFICIALI="avidemux build-essential bwm-ng cmatrix compizconfig-settings-manager conky deluge-torrent emesene exaile filezilla finch fusion-icon gmail-notify gnome-art gnome-commander gnome-mplayer gparted gthumb gtk-recordmydesktop hardinfo hddtemp htop iotop k3b kde-i18n-it lm-sensors mc meld mplayer msttcorefonts mumble nautilus-actions nautilus-image-converter nautilus-open-terminal nfs-common nfs-kernel-server ntfsprogs openoffice.org p7zip p7zip-full p7zip-rar padevchooser pidgin powertop pwgen rar sensors-applet smartmontools soundconverter startupmanager subtitleeditor sun-java6-plugin tagtool tofrodos ubuntu-restricted-extras vim vlc vlc-plugin-pulse zlib1g-dev"

APPZ_ALTRI_REPO="$WXXCODECS libdvdcss2 ubuntu-tweak"

APPZ="$APPZ_REPO_UFFICIALI $APPZ_ALTRI_REPO"

while getopts :ahv OPZIONE
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
	echo "Questo script è utilizzabile esclusivamente su Ubuntu 9.10 Karmic Koala"
	echo "Info sulla tua distribuzione:"
	lsb_release -d -c
	exit 1
fi


if [[ $EUID -ne 0 ]]
then
	echo "Lo script richiede l'esecuzione con i permessi di root." 1>&2
	chmod 777 ./`basename $0`
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
	echo "Aggiunto"
	if [[ $# -gt 2 ]]
	then
		echo -n "Importazione chiave di $1: "
		wget -q $3 -O- | sudo apt-key add -
		sleep 6
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


REPOLIST="Medibuntu, OpenOffice.org 3, VLC, Deluge, Ubuntu Tweak, Skype, VirtualBox"

PINGSITE="www.google.com"

PARTNER="deb http://archive.canonical.com/ubuntu karmic partner"
PARTNER_SRC="deb-src http://archive.canonical.com/ubuntu karmic partner"
PARTNER_SED='sed -i -e "s/# deb http:\/\/archive.canonical.com\/ubuntu karmic partner/deb http:\/\/archive.canonical.com\/ubuntu karmic partner/g" /etc/apt/sources.list'
PARTNER_SRC_SED='sed -i -e "s/# deb-src http:\/\/archive.canonical.com\/ubuntu karmic partner/deb-src http:\/\/archive.canonical.com\/ubuntu karmic partner/g" /etc/apt/sources.list'

BACKPORTS="deb http://it.archive.ubuntu.com/ubuntu/ karmic-backports main restricted universe multiverse"
BACKPORTS_SRC="deb-src http://it.archive.ubuntu.com/ubuntu/ karmic-backports main restricted universe multiverse"
BACKPORTS_SED='sed -i -e "s/# deb http:\/\/it.archive.ubuntu.com\/ubuntu\/ karmic-backports main restricted universe multiverse/deb http:\/\/it.archive.ubuntu.com\/ubuntu\/ karmic-backports main restricted universe multiverse/g" /etc/apt/sources.list'
BACKPORTS_SRC_SED='sed -i -e "s/# deb-src http:\/\/it.archive.ubuntu.com\/ubuntu\/ karmic-backports main restricted universe multiverse/deb-src http:\/\/it.archive.ubuntu.com\/ubuntu\/ karmic-backports main restricted universe multiverse/g" /etc/apt/sources.list'


MEDIBUNTU="deb http://packages.medibuntu.org/ $DISTRIBUZIONE free non-free"
MEDIBUNTU_KEY="http://packages.medibuntu.org/medibuntu-key.gpg"
SKYPE="deb http://download.skype.com/linux/repos/debian stable non-free"
DROPBOX="deb http://linux.dropbox.com/ubuntu $DISTRIBUZIONE main"
DROPBOX_SRC="deb-src http://linux.dropbox.com/ubuntu $DISTRIBUZIONE main"
VIRTUALBOX="deb http://download.virtualbox.org/virtualbox/debian $DISTRIBUZIONE non-free"
VIRTUALBOX_KEY="http://download.virtualbox.org/virtualbox/debian/sun_vbox.asc"
VBOX_USB="none /proc/bus/usb usbfs devgid=125,devmode=664 0 0"
#GOOGLE_KEY="https://dl-ssl.google.com/linux/linux_signing_key.pub"
GETDEB="deb http://archive.getdeb.net/ubuntu karmic-getdeb apps"
GETDEB_KEY="http://archive.getdeb.net/getdeb-archive.key"

echo "Questo script aggiungerà al source.list i seguenti repository per Ubuntu 9.10 \"Karmic Koala\":"
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
apt-get upgrade

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
enable_repo "Ubuntu Karmic-Backports" "$BACKPORTS" "$BACKPORTS_SED"
enable_repo "Ubuntu Karmic-Backports (Sorgenti)" "$BACKPORTS_SRC" "$BACKPORTS_SRC_SED"

add-apt-repository ppa:tualatrix/ppa #Ubuntu-Tweak
add-apt-repository ppa:c-korn/vlc #VLC
add-apt-repository ppa:ubuntu-x-swat/x-updates #X-Updates
add-apt-repository ppa:slicer/ppa #Mumble
#add-apt-repository ppa:subdownloader-developers/ppa #SubDownloader
#add-apt-repository ppa:pkg-games/ppa #pkg-games
#add-apt-repository ppa:deluge-team #Deluge"
#add-apt-repository ppa:openoffice-pkgs #OpenOffice.org
add_repo "medibuntu" "$MEDIBUNTU" "$MEDIBUNTU_KEY"
add_repo "virtualbox" "$VIRTUALBOX" "$VIRTUALBOX_KEY"
add_repo "dropbox" "$DROPBOX"
add_repo "getdeb" "$GETDEB" "$GETDEB_KEY"
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
apt-get upgrade
echo
echo "=== Installazione pacchetti ==="
echo
sleep 1
apt-get install $APPZ
apt-get remove postfix

exit 0
