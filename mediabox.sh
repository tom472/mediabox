#!/bin/bash

# Get local Username
localuname=`id -u -n`
# Get PUID
PUID=`id -u $localuname`
# Get GUID
PGID=`id -g $localuname`
# Get Hostname
thishost=`hostname`
# Get IP Address and Time Zone
if [ `uname` == 'Darwin' ]; then
    locip=`(ifconfig en0 || ifconfig en1) | grep 'inet ' | awk '{print $2}'`
    time_zone=`ls -l /etc/localtime | sed -E 's/.*zoneinfo\/(.*)$/\1/'`
else
    locip=`hostname -I | awk '{print $1}'`
    time_zone=`cat /etc/timezone`
fi

# CIDR - this assumes a 255.255.255.0 netmask - If your config is different use the custom CIDR line
lannet=`echo $locip | sed 's/\.[0-9]*$/.0\/24/'`
# Custom CIDR (comment out the line above if using this)
# Uncomment the line below and enter your CIDR info so the line looks like: lannet=xxx.xxx.xxx.0/24
#lannet=

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

# Get the desired directory for media storage
read -p "Where do you want to store media? By default './content' will be used: " mediadirectory
if [ -z "$mediadirectory" ]; then
   mediadirectory='./content'
fi
# If the user entered '~' in the path, replace it with '$HOME' so it gets properly expanded
mediadirectory="${mediadirectory/#\~/$HOME}"

# Get the desired directory for media storage
read -p "Where do you want to store configuation data? By default '.' (this directory) will be used: " datadirectory
if [ -z "$datadirectory" ]; then
   datadirectory='.'
fi
# If the user entered '~' in the path, replace it with '$HOME' so it gets properly expanded
datadirectory="${datadirectory/#\~/$HOME}"

# Create the directory structure
mkdir -p "$mediadirectory"/completed
mkdir -p "$mediadirectory"/incomplete
mkdir -p "$mediadirectory"/movies
mkdir -p "$mediadirectory"/tv
mkdir -p "$datadirectory"/couchpotato
mkdir -p "$datadirectory"/delugevpn
mkdir -p "$datadirectory"/delugevpn/config/openvpn
mkdir -p "$datadirectory"/duplicati
mkdir -p "$datadirectory"/duplicati/backups
mkdir -p "$datadirectory"/ombi
mkdir -p "$datadirectory/plex/Library/Application Support/Plex Media Server/Logs"
mkdir -p "$datadirectory"/plexpy
mkdir -p "$datadirectory"/portainer
mkdir -p "$datadirectory"/radarr
mkdir -p "$datadirectory"/sickrage
mkdir -p "$datadirectory"/www
# Move the PIA VPN files
cp ca.ovpn "$datadirectory"/delugevpn/config/openvpn/ca.ovpn
cp ca.rsa.2048.crt "$datadirectory"/delugevpn/config/openvpn/ca.rsa.2048.crt
cp crl.rsa.2048.pem "$datadirectory"/delugevpn/config/openvpn/crl.rsa.2048.pem

###################
# TROUBLESHOOTING #
###################
# If you are having issues with any containers starting
# Or the .env file is not being populated with the correct values
# Uncomment the necessary line(s) below to see what values are being generated

# printf "### Collected Variables are echoed below. ###\n"
# printf "\n"
# printf "The username is: $localuname\n"
# printf "The IP address is: $locip\n"
# printf "The PUID is: $PUID\n"
# printf "The PGID is: $PGID\n"
# printf "The CIDR address is: $lannet\n"
# printf "The PIA Username is: $piauname\n"
# printf "The PIA Password is: $piapass\n"
# printf "The Hostname is: $thishost\n"
# printf "The Timezone is: $time_zone\n"
# printf "The Plex version is: $pmstag\n"
# printf "The Plexpass Claim token is: $pmstoken\n"
# printf "The Portainer style is: $portainerstyle\n"
# printf "Note: A Portainer style of 'blank' = the 'Normal Auth' style\n"
# printf "The Media Directory is: $mediadirectory\n"
# printf "The Data/Config Directory is: $datadirectory\n"

# Create the .env file
echo "Creating the .env file with the values we have gathered"
printf "\n"
echo "LOCALUSER=$localuname" >> .env
echo "HOSTNAME=$thishost" >> .env
echo "IP_ADDRESS=$locip" >> .env
echo "PUID=$PUID" >> .env
echo "PGID=$PGID" >> .env
echo "CIDR_ADDRESS=$lannet" >> .env
echo "PIAUNAME=$piauname" >> .env
echo "PIAPASS=$piapass" >> .env
echo "TZ=$time_zone" >> .env
echo "PMSTAG=$pmstag" >> .env
echo "PMSTOKEN=$pmstoken" >> .env
echo "PORTAINERSTYLE=$portainerstyle" >> .env
echo "MEDIADIRECTORY=$mediadirectory" >> .env
echo "DATADIRECTORY=$datadirectory" >> .env
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
while [ ! -f "$datadirectory"/delugevpn/config/core.conf ]; do sleep 1; done
docker stop delugevpn > /dev/null 2>&1
rm -f "$datadirectory"/delugevpn/config/core.conf~ > /dev/null 2>&1
perl -i -pe 's/"allow_remote": false,/"allow_remote": true,/g'  "$datadirectory"/delugevpn/config/core.conf
perl -i -pe 's/"move_completed": false,/"move_completed": true,/g'  "$datadirectory"/delugevpn/config/core.conf
docker start delugevpn > /dev/null 2>&1

# Push the Deluge Daemon Access info the to Auth file
echo $daemonun:$daemonpass:10 >> "$datadirectory"/delugevpn/config/auth

# Configure UHTTPD settings and Index file
docker stop uhttpd > /dev/null 2>&1
cp index.html "$datadirectory"/www/index.html
perl -i -pe "s/locip/$locip/g" "$datadirectory"/www/index.html
perl -i -pe "s/daemonun/$daemonun/g" "$datadirectory"/www/index.html
perl -i -pe "s/daemonpass/$daemonpass/g" "$datadirectory"/www/index.html
cp .env "$datadirectory"/www/env.txt
docker start uhttpd > /dev/null 2>&1

# Fix the Healthcheck in Minio
docker exec minio sed -i "s/404/403/g" /usr/bin/healthcheck.sh

# Adjust the permissions on the media folder
chmod -R 0777 "$mediadirectory"

printf "Setup Complete - Open a browser and go to: \n\n"
printf "http://$locip OR http://$thishost \n"
