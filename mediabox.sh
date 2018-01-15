#!/bin/bash

#set -x

# Get local Username
localuname=`id -u -n`
# Get PUID
PUID=`id -u $localuname`
# Get GUID
PGID=`id -g $localuname`
# Get Hostname
thishost=`hostname`
# Get IP Address
locip=`hostname -I | awk '{print $1}'`
# Get Time Zone
time_zone=`cat /etc/timezone`

# an accurate way to calculate the local network
# Use ifconfig to grab the subnet mask of locip
# Then AND it with locip to get the correct network
# Should work regardless of IP or subnet mask
# Should work with VLSM and CIDR
# Grab the subnet mask from ifconfig
subnet_mask=$(ifconfig | grep $locip | awk -F ':' {'print $4'})
# Use bitwise & with ip and mask to calculate network address
IFSold=$IFS
IFS=. read -r i1 i2 i3 i4 <<< $locip
IFS=. read -r m1 m2 m3 m4 <<< $subnet_mask
IFS=$IFSold
lannet=$(printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))")

# Converts subnet mask into CIDR notation
# thanks to https://stackoverflow.com/questions/20762575/explanation-of-convertor-of-cidr-to-netmask-in-linux-shell-netmask2cdir-and-cdir
# because I kept messing it up.
#
# Define the function first, takes subnet as positional parameters
function mask2cdr()
{
   # Assumes there's no "255." after a non-255 byte in the mask
   local x=${1##*255.}
   set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#x})*2 )) ${x%%.*}
   x=${1%%$3*}
   cidr_bits=$(( $2 + (${#x}/4) ))
}
mask2cdr $subnet_mask # Call the function to convert to CIDR
lannet=$(echo "$lannet/$cidr_bits") # Combine lannet and cidr

# Get Private Internet Access Info
read -p "What is your PIA Username?: " piauname
read -s -p "What is your PIA Password? (Will not be echoed): " piapass
printf "\n\n"

# Get info needed for PLEX Official image
read -p "Which PLEX release do you want to run? By default 'public' will be used. (latest, public, plexpass): " pmstag
read -p "If you have PLEXPASS what is your Claim Token from https://www.plex.tv/claim/ (Optional): " pmstoken
# If not set - set PMS Tag to Public:
if [ -z "$pmstag" ]; then 
   pmstag=public 
fi

# Get the info for the style of Portainer to use
read -p "Which style of Portainer do you want to use? By default 'No Auth' will be used. (noauth, auth): " portainerstyle
if [ -z "$portainerstyle" ]; then
   portainerstyle=--no-auth
elif [ $portainerstyle == "noauth" ]; then
   portainerstyle=--no-auth
elif [ $portainerstyle == "auth" ]; then
   portainerstyle= 
fi   

# Create the directory structure
mkdir -p content/completed
mkdir -p content/incomplete
mkdir -p content/movies
mkdir -p content/tv
mkdir -p couchpotato
mkdir -p delugevpn
mkdir -p delugevpn/config/openvpn
mkdir -p duplicati
mkdir -p duplicati/backups
mkdir -p jackett
mkdir -p minio
mkdir -p ombi
mkdir -p "plex/Library/Application Support/Plex Media Server/Logs"
mkdir -p plexpy
mkdir -p portainer
mkdir -p radarr
mkdir -p sickrage
mkdir -p sonarr
mkdir -p www
# Move the PIA VPN files
mv ca.ovpn delugevpn/config/openvpn/ca.ovpn > /dev/null 2>&1
mv ca.rsa.2048.crt delugevpn/config/openvpn/ca.rsa.2048.crt > /dev/null 2>&1
mv crl.rsa.2048.pem delugevpn/config/openvpn/crl.rsa.2048.pem > /dev/null 2>&1

###################
# TROUBLESHOOTING #
###################
# If you are having issues with any containers starting
# Or the .env file is not being populated with the correct values
# Uncomment the necessary line(s) below to see what values are being generated

# printf "### Collected Variables are echoed below. ###\n"
# printf "\n"
# printf "The username is: $localuname\n"
# printf "The PUID is: $PUID\n"
# printf "The PGID is: $PGID\n"
# printf "The current directory is: $PWD\n"
# printf "The IP address is: $locip\n"
# printf "The CIDR address is: $lannet\n"
# printf "The PIA Username is: $piauname\n"
# printf "The PIA Password is: $piapass\n"
# printf "The Hostname is: $thishost\n"
# printf "The Timezone is: $time_zone\n"
# printf "The Plex version is: $pmstag\n"
# printf "The Plexpass Claim token is: $pmstoken\n"
# printf "The Portainer style is: $portainerstyle\n"
# printf "Note: A Portainer style of 'blank' = the 'Normal Auth' style\n"

# Create the .env file
echo "Creating the .env file with the values we have gathered"
printf "\n"
echo "LOCALUSER=$localuname" >> .env
echo "HOSTNAME=$thishost" >> .env
echo "IP_ADDRESS=$locip" >> .env
echo "PUID=$PUID" >> .env
echo "PGID=$PGID" >> .env
echo "PWD=$PWD" >> .env
echo "PIAUNAME=$piauname" >> .env
echo "PIAPASS=$piapass" >> .env
echo "CIDR_ADDRESS=$lannet" >> .env
echo "TZ=$time_zone" >> .env
echo "PMSTAG=$pmstag" >> .env
echo "PMSTOKEN=$pmstoken" >> .env
echo "PORTAINERSTYLE=$portainerstyle" >> .env
echo ".env file creation complete"
printf "\n\n"

# Download & Launch the containers
echo "The containers will now be pulled and launched"
echo "This may take a while depending on your download speed"
read -p "Press any key to continue... " -n1 -s
printf "\n\n"
docker-compose up -d
printf "\n\n"

# Let's configure the access to the Deluge Daemon for CouchPotato
echo "CouchPotato requires access to the Deluge daemon port and needs credentials set."
read -p "What would you like to use as the daemon access username?: " daemonun
read -p "What would you like to use as the daemon access password?: " daemonpass
printf "\n\n"

# Finish up the config
printf "Configuring Deluge daemon access - UHTTPD index file - Permissions \n\n"

# Configure DelugeVPN: Set Daemon access on, delete the core.conf~ file
while [ ! -f delugevpn/config/core.conf ]; do sleep 1; done
docker stop delugevpn > /dev/null 2>&1
rm delugevpn/config/core.conf~ > /dev/null 2>&1
perl -i -pe 's/"allow_remote": false,/"allow_remote": true,/g'  delugevpn/config/core.conf
perl -i -pe 's/"move_completed": false,/"move_completed": true,/g'  delugevpn/config/core.conf
docker start delugevpn > /dev/null 2>&1

# Push the Deluge Daemon Access info the to Auth file
echo $daemonun:$daemonpass:10 >> ./delugevpn/config/auth

# Configure UHTTPD settings and Index file
docker stop uhttpd > /dev/null 2>&1
mv index.html www/index.html
perl -i -pe "s/locip/$locip/g" www/index.html
perl -i -pe "s/daemonun/$daemonun/g" www/index.html
perl -i -pe "s/daemonpass/$daemonpass/g" www/index.html
cp .env www/env.txt
docker start uhttpd > /dev/null 2>&1

# Fix the Healthcheck in Minio
docker exec minio sed -i "s/404/403/g" /usr/bin/healthcheck.sh

# Adjust the permissions on the content folder
chmod -R 0777 content/

printf "Setup Complete - Open a browser and go to: \n\n"

# Worth pointing out that using thishost for the domain name
# from another computer will only work if thishost is a FQDN
# as seen using hostname -f Or if the client computer has it
# its hostfile.
# TL:DR it will only work if the client's DNS method has
# thishost mapped to the same IP address as locip. Which 
# there is a good chance it doesn't.
printf "http://$locip OR http://$thishost \n"
