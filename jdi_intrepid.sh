#!/bin/bash
# JD
# TODO:
# *) Scrivere una breve descrizione del programma al posto del commento #JD
# *) Visualizzare l'elenco delle applicazioni e dei repo da aggiungere solo su esplicita richiesta dell'utente (es: opzioni -l -r)
# *) Installazione selettiva dei repository esterni e delle applicazioni a essi legate
# *) Prevedere un "dpkg --config -a" in caso di problemi
# *) Dare un qualche tipo di ordine alla lista dei pacchetti
#

lsb_release -c | grep -q intrepid 
if [[ $? -ne 0 ]]
then
	echo "Questo script è utilizzabile esclusivamente su Ubuntu 8.10 Intrepid Ibex"
	echo "Info sulla tua attuale distribuzione:"
	lsb_release -a
	exit 1
fi

if [[ $EUID -ne 0 ]]
then
	echo "Lo script richiede l'esecuzione con i permessi di root." 1>&2
	sudo ./`basename $0`
	exit 0
fi

function add_repo {
echo -n "Repository di $1: "
if cat /etc/apt/sources.list | grep -q "$2"
then
	echo "Già presente"
else
	echo "$2 #$1" >> /etc/apt/sources.list
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
	add_repo "$1" "$2"
fi

}

APPZ="tofrodos mc vim vim-full nfs-common nfs-kernel-server ubuntu-restricted-extras w32codecs vlc mplayer gnome-mplayer nautilus-open-terminal nautilus-image-converter nautilus-actions htop powertop bwm-ng finch build-essential epiphany-browser gftp startupmanager gmail-notify hardinfo zlib1g-dev hddtemp lm-sensors sensors-applet gparted ntfsprogs openoffice.org sun-java6-plugin gnome-commander avidemux gtk-recordmydesktop subtitleeditor deluge-torrent epiphany-browser kompare fusion-icon ubuntu-tweak padevchooser conky smartmontools cmatrix skype virtualbox-2.1 emesene libdvdcss2 p7zip p7zip-full p7zip-rar rar mumble compizconfig-settings-manager k3b k3b-i18n kde-i18n-it"

REPOLIST="Medibuntu, OpenOffice.org 3, VLC, Deluge, Ubuntu Tweak, Skype, VirtualBox"

PINGSITE="www.google.com"

PARTNER="deb http://archive.canonical.com/ubuntu intrepid partner"
PARTNER_SRC="deb-src http://archive.canonical.com/ubuntu intrepid partner"
PARTNER_SED='sed -i -e "s/# deb http:\/\/archive.canonical.com\/ubuntu intrepid partner/deb http:\/\/archive.canonical.com\/ubuntu intrepid partner/g" /etc/apt/sources.list'
PARTNER_SRC_SED='sed -i -e "s/# deb-src http:\/\/archive.canonical.com\/ubuntu intrepid partner/deb-src http:\/\/archive.canonical.com\/ubuntu intrepid partner/g" /etc/apt/sources.list'

BACKPORTS="deb http://it.archive.ubuntu.com/ubuntu/ intrepid-backports main restricted universe multiverse"
BACKPORTS_SRC="deb-src http://it.archive.ubuntu.com/ubuntu/ intrepid-backports main restricted universe multiverse"
BACKPORTS_SED='sed -i -e "s/# deb http:\/\/it.archive.ubuntu.com\/ubuntu\/ intrepid-backports main restricted universe multiverse/deb http:\/\/it.archive.ubuntu.com\/ubuntu\/ intrepid-backports main restricted universe multiverse/g" /etc/apt/sources.list'
BACKPORTS_SRC_SED='sed -i -e "s/# deb-src http:\/\/it.archive.ubuntu.com\/ubuntu\/ intrepid-backports main restricted universe multiverse/deb-src http:\/\/it.archive.ubuntu.com\/ubuntu\/ intrepid-backports main restricted universe multiverse/g" /etc/apt/sources.list'


MEDIBUNTU="deb http://packages.medibuntu.org/ intrepid free non-free"
MEDIBUNTU_KEY="http://packages.medibuntu.org/medibuntu-key.gpg"
UBUNTU_TWEACK="deb http://ppa.launchpad.net/tualatrix/ubuntu intrepid main"
UBUNTU_TWEACK_SRC="deb-src http://ppa.launchpad.net/tualatrix/ubuntu intrepid main"
UBUNTU_TWEACK_KEY="0624A220"
VLC="deb http://ppa.launchpad.net/c-korn/ubuntu intrepid main"
VLC_SRC="deb-src http://ppa.launchpad.net/c-korn/ubuntu intrepid main"
VLC_KEY="E0E36533196F82F6D4C97AAD71346C8340130828"
DELUGE="deb http://ppa.launchpad.net/deluge-team/ubuntu intrepid main"
DELUGE_SRC="deb-src http://ppa.launchpad.net/deluge-team/ubuntu intrepid main"
DELUGE_KEY="249AD24C"
OOO3="deb http://ppa.launchpad.net/openoffice-pkgs/ubuntu intrepid main"
OOO3_SRC="deb-src http://ppa.launchpad.net/openoffice-pkgs/ubuntu intrepid main"
OOO3_KEY="247D1CFF"
SKYPE="deb http://download.skype.com/linux/repos/debian stable non-free"
DROPBOX="deb http://linux.getdropbox.com/ubuntu intrepid main"
DROPBOX_SRC="deb-src http://linux.getdropbox.com/ubuntu intrepid main"
VIRTUALBOX="deb http://download.virtualbox.org/virtualbox/debian intrepid non-free"
VIRTUALBOX_KEY="http://download.virtualbox.org/virtualbox/debian/sun_vbox.asc"
VBOX_USB="none /proc/bus/usb usbfs devgid=125,devmode=664 0 0"
MUMBLE="deb http://ppa.launchpad.net/slicer/ubuntu intrepid main"
MUMBLE_SRC="deb-src http://ppa.launchpad.net/slicer/ubuntu intrepid main"
MUMBLE_KEY="165B2836"
SYNCE="deb http://ppa.launchpad.net/synce/ubuntu intrepid main"
SYNCE_SRC="deb-src http://ppa.launchpad.net/synce/ubuntu intrepid main"
SYNCE_KEY="D246C25D"
SUBDOWNLOADER="deb http://ppa.launchpad.net/subdownloader-developers/ppa/ubuntu intrepid main"
SUBDOWNLOADER_SRC="deb-src http://ppa.launchpad.net/subdownloader-developers/ppa/ubuntu intrepid main"
SUBDOWNLOADER_KEY="2847688F"
#AWN="deb http://ppa.launchpad.net/reacocard-awn/ubuntu/ intrepid main"
#MUCOMMANDER="deb http://apt.mucommander.com unstable main non-free contrib"
#GOOGLE_KEY="https://dl-ssl.google.com/linux/linux_signing_key.pub"

PPA_ADD_KEY="sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com"

echo "Questo script aggiungerà al source.list i seguenti repository per Ubuntu 8.10 \"Intrepid Ibex\":"
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
enable_repo "Ubuntu Intrepid-Backports" "$BACKPORTS" "$BACKPORTS_SED"
enable_repo "Ubuntu Intrepid-Backports (Sorgenti)" "$BACKPORTS_SRC" "$BACKPORTS_SRC_SED"

add_repo "Medibuntu" "$MEDIBUNTU" "$MEDIBUNTU_KEY"
add_repo "Virtualbox" "$VIRTUALBOX" "$VIRTUALBOX_KEY"
add_repo "Ubuntu-Tweak" "$UBUNTU_TWEACK"
add_repo "Ubuntu-Tweak (Sorgenti)" "$UBUNTU_TWEACK_SRC"
$PPA_ADD_KEY $UBUNTU_TWEACK_KEY
add_repo "VLC" "$VLC"
add_repo "VLC (Sorgenti)" "$VLC_SRC"
$PPA_ADD_KEY $VLC_KEY
add_repo "Deluge" "$DELUGE"
add_repo "Deluge (Sorgenti)" "$DELUGE_SRC"
$PPA_ADD_KEY $DELUGE_KEY
add_repo "OpenOffice.org 3" "$OOO3"
add_repo "OpenOffice.org 3 (Sorgenti)" "$OOO3_SRC"
$PPA_ADD_KEY $OOO3_KEY
add_repo "Skype" "$SKYPE"
add_repo "Dropbox" "$DROPBOX"
add_repo "Dropbox (Sorgenti)" "$DROPBOX_SRC"
add_repo "Mumble" "$MUMBLE"
add_repo "Mumble (Sorgenti)" "$MUMBLE_SRC"
$PPA_ADD_KEY $MUMBLE_KEY
add_repo "SynCE" "$SYNCE"
add_repo "SynCE (Sorgenti)" "$SYNCE_SRC"
$PPA_ADD_KEY $SYNCE_KEY
add_repo "SubDownloader" "$SUBDOWNLOADER"
add_repo "SubDownloader (Sorgenti)" "$SUBDOWNLOADER_SRC"
$PPA_ADD_KEY $SUBDOWNLOADER_KEY

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

exit 0
