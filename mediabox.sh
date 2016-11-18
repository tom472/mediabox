#!/bin/bash

# Must be root to use this tool
if [[ ! $EUID -eq 0 ]];then
  if [ -x "$(command -v sudo)" ];then
		export SUDO="sudo"
  else
    echo "::: Please install sudo or run this as root."
    exit 1
  fi
fi

# Capture Hostname
thishost=$(hostname)

# Install Docker
$SUDO curl -fsSL https://get.docker.com/ | sh

# Get base Mounted Volumes path for containers
echo "What is the base path of the directory that you want to use for your mounted volumes : \n i.e. /dockervols"
read -e BASEDIR
$SUDO mkdir $BASEDIR

if $rancher = true
then
$SUDO mkdir -p $BASEDIR/rancher
read -p "What port do you want to use for Rancher? (Press enter for default 8080): " -e -i 8080 rancherip

$SUDO mkdir -p $BASEDIR/delugevpn/data/complete
$SUDO mkdir -p $BASEDIR/delugevpn/data/downloading
$SUDO mkdir -p $BASEDIR/delugevpn/config
read -p "What port do you want to use for DelugeVPN? (Press enter for default 8112): " -e -i 8112 delugevpnip
read -p "What is your PIA Username?: " piauname
read -s -p "What is you PIA Password? (Will not be echoed): " piapass
read -p "We need your PIUD and GUID for this container .. What is your username on this PC?" localuname
$PUID=id -u $localuname
$GUID=id -g $localuname
read -p "We need the CIDR network notation for your local network i.e. 192.168.0.1/24: " -e -i 192.168.0.1/24 lannet

read -s -p "Password:" 
