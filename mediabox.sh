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

# An accurate way to calculate the local network
# via @kspillane
# Grab the subnet mask from ifconfig
subnet_mask=$(ifconfig | grep $locip | awk -F ':' {'print $4'})
# Use bitwise & with ip and mask to calculate network address
IFSold=$IFS
IFS=. read -r i1 i2 i3 i4 <<< $locip
IFS=. read -r m1 m2 m3 m4 <<< $subnet_mask
IFS=$IFSold
lannet=$(printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))")

# Converts subnet mask into CIDR notation
# Thanks to https://stackoverflow.com/questions/20762575/explanation-of-convertor-of-cidr-to-netmask-in-linux-shell-netmask2cdir-and-cdir
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
mkdir -p muximux
mkdir -p nzbget
mkdir -p ombi
mkdir -p "plex/Library/Application Support/Plex Media Server/Logs"
mkdir -p portainer
mkdir -p radarr
mkdir -p sickrage
mkdir -p sonarr
mkdir -p tautulli

# Select and Move the PIA VPN files
# Create a menu selection
echo "The following PIA Servers are avialable that support port-forwarding (for DelugeVPN); Please select one:"
PS3="Use a number to select a Server File or 'c' to cancel: "
# List the ovpn files
select filename in ovpn/*.ovpn
do
    # leave the loop if the user says 'c'
    if [[ "$REPLY" == c ]]; then break; fi
    # complain if no file was selected, and loop to ask again
    if [[ "$filename" == "" ]]
    then
        echo "'$REPLY' is not a valid number"
        continue
    fi
    # now we can use the selected file
    echo "$filename selected"
    cp $filename delugevpn/config/openvpn/ > /dev/null 2>&1
    vpnremote=`cat $filename | grep "remote" | cut -d ' ' -f2  | head -1`
    # it'll ask for another unless we leave the loop
    break
done
# TODO - Add a default server selection if none selected .. 
cp ovpn/*.crt delugevpn/config/openvpn/ > /dev/null 2>&1
cp ovpn/*.pem delugevpn/config/openvpn/ > /dev/null 2>&1

# Create the .env file
echo "Creating the .env file with the values we have gathered"
printf "\n"
cat << EOF > .env
###  ------------------------------------------------
###  M E D I A B O X   C O N F I G   S E T T I N G S
###  ------------------------------------------------
###  The values configured here are applied during
###  $ docker-compose up
###  -----------------------------------------------
###  DOCKER-COMPOSE ENVIRONMENT VARIABLES BEGIN HERE
###  -----------------------------------------------
###
EOF
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
echo "VPN_REMOTE=$vpnremote" >> .env
echo ".env file creation complete"
printf "\n\n"

# Adjust for the Tautulli replacement of PlexPy
docker rm -f plexpy > /dev/null 2>&1

# Download & Launch the containers
echo "The containers will now be pulled and launched"
echo "This may take a while depending on your download speed"
read -p "Press any key to continue... " -n1 -s
printf "\n\n"
docker-compose up -d
printf "\n\n"

# Let's configure the access to the Deluge Daemon and
# The same credentials can be used for NZBGet's webui
#
# NZBGet can be configured to not use a user/pass to access the webui
# but in case this isnt being ran on a home network, it's best to put it in
echo "You need to set a username and password for programs to access"
echo "Deluge daemon and NZBGet's API and web interface."
read -p "What would you like to use as the access username?: " daemonun
read -p "What would you like to use as the access password?: " daemonpass
printf "\n\n"

# Finish up the config
printf "Configuring DelugeVPN and NZBGet - Muximux files - Permissions \n"
printf "This may take a few minutes...\n\n"

# Configure DelugeVPN: Set Daemon access on, delete the core.conf~ file
while [ ! -f delugevpn/config/core.conf ]; do sleep 1; done
docker stop delugevpn > /dev/null 2>&1
rm delugevpn/config/core.conf~ > /dev/null 2>&1
perl -i -pe 's/"allow_remote": false,/"allow_remote": true,/g'  delugevpn/config/core.conf
perl -i -pe 's/"move_completed": false,/"move_completed": true,/g'  delugevpn/config/core.conf
docker start delugevpn > /dev/null 2>&1

# Configure NZBGet
while [ ! -f nzbget/nzbget.conf ]; do sleep 1; done
docker stop nzbget > /dev/null 2>&1
perl -i -pe "s/ControlUsername=nzbget/ControlUsername=$daemonun/g"  nzbget/nzbget.conf
perl -i -pe "s/ControlPassword=tegbzn6789/ControlPassword=$daemonpass/g"  nzbget/nzbget.conf
docker start nzbget > /dev/null 2>&1

# Push the Deluge Daemon and NZBGet Access info the to Auth file - and to the .env file
echo $daemonun:$daemonpass:10 >> ./delugevpn/config/auth
echo "CPDAEMONUN=$daemonun" >> .env
echo "CPDAEMONPASS=$daemonpass" >> .env
echo "NZBGETUN=$daemonun" >> .env
echo "NZBGETPASS=$daemonpass" >> .env

# Configure Muximux settings and files
docker stop muximux > /dev/null 2>&1
cp settings.ini.php muximux/www/muximux/settings.ini.php
cp mediaboxconfig.php muximux/www/muximux/mediaboxconfig.php
cp .env muximux/www/muximux/env.txt
perl -i -pe "s/locip/$locip/g" muximux/www/muximux/settings.ini.php
perl -i -pe "s/locip/$locip/g" muximux/www/muximux/mediaboxconfig.php
perl -i -pe "s/daemonun/$daemonun/g" muximux/www/muximux/mediaboxconfig.php
perl -i -pe "s/daemonpass/$daemonpass/g" muximux/www/muximux/mediaboxconfig.php
docker start muximux > /dev/null 2>&1

# If PlexPy existed - copy plexpy.db to Tautulli 
if [ -e plexpy/plexpy.db ]; then
    docker stop tautulli > /dev/null 2>&1
    mv tautulli/tautulli.db tautulli/tautulli.db.orig
    cp plexpy/plexpy.db tautulli/tautulli.db
    mv plexpy/plexpy.db plexpy/plexpy.db.moved
    docker start tautulli > /dev/null 2>&1
    exit 0
fi

# Fix the Healthcheck in Minio
docker exec minio sed -i "s/404/403/g" /usr/bin/healthcheck.sh

# Adjust the permissions on the content folder
chmod -R 0777 content/

printf "Setup Complete - Open a browser and go to: \n\n"
printf "http://$locip \nOR http://$thishost If you have appropriate DNS configured.\n\n"
printf "Start with the MEDIABOX Icon for settings and configuration info.\n"