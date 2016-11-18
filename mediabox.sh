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

# Get local Username
localuname=id -u -n

# Get PUID
$PUID=id -u $localuname

# Get GUID
$GUID=id -g $localuname

# Get Hostname
thishost=$(hostname)

# Get IP Address
locip=hostname -I | awk '{print $1}'

# CIDR - this assumes a 255.255.255.0 netmask - If your config is different use the custom CIDR line
lannet=hostname -I | awk '{print $1}' | sed 's/\.[0-9]*$/.0\/24/'
# Custom CIDR (comment out the line above if using this) 
# Uncomment the line below and enter your CIDR info so the line looks like: lannet=xxx.xxx.xxx.0/24
#lannet=

# Install Docker
$SUDO curl -fsSL https://get.docker.com/ | sh

read -p "What is your PIA Username?: " piauname
read -s -p "What is you PIA Password? (Will not be echoed): " piapass
