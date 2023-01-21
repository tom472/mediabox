#!/bin/bash

# Check that script was run not as root or with sudo
if [ "$EUID" -eq 0 ]
  then echo "Please do not run this script as root or using sudo"
  exit
fi

# See if we need to check GIT for updates
if [ -e .env ]; then
    # Check for Updated Docker-Compose
    printf "Checking for update to Docker-Compose (If needed - You will be prompted for SUDO credentials).\\n\\n"
    onlinever=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "tag_name" | cut -d ":" -f2 | sed 's/"//g' | sed 's/,//g' | sed 's/ //g')
    printf "Current online version is: %s \\n" "$onlinever"
    localver=$(docker-compose -v | cut -d " " -f4 | sed 's/,//g')
    printf "Current local version is: %s \\n" "$localver"
    if [ "$localver" != "$onlinever" ]; then
        sudo curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "browser_download_url" | grep -i -m1 "$(uname -s)"-"$(uname -m)" | cut -d '"' -f4 | xargs sudo curl -L -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        printf "\\n\\n"
    else
        printf "No Docker-Compose Update needed.\\n\\n"
    fi
    # Stash any local changes to the base files
    git stash > /dev/null 2>&1
    printf "Updating your local copy of Mediabox.\\n\\n"
    # Pull the latest files from Git
    git pull
    # Check to see if this script "mediabox.sh" was updated and restart it if necessary
    changed_files="$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD)"
    # Provide a message once the Git check/update  is complete
    if [ -z "$changed_files" ]; then
        printf "Your Mediabox is current - No Update needed.\\n\\n"
    else
        printf "Mediabox Files Update complete.\\n\\nThis script will restart if necessary\\n\\n"
    fi
    # Rename the .env file so this check fails if mediabox.sh needs to re-launch
    mv .env 1.env
    read -r -p "Press any key to continue... " -n1 -s
    printf "\\n\\n"
    # Run exec mediabox.sh if mediabox.sh changed
    grep --q "$changed_files" mediabox.sh && echo "mediabox.sh restarting" && exec $0
fi

# After update collect some current known variables
if [ -e 1.env ]; then
    # Grab the CouchPotato, NBZGet, & PIA usernames & passwords to reuse
    daemonun=$(grep CPDAEMONUN 1.env | cut -d = -f2)
    daemonpass=$(grep CPDAEMONPASS 1.env | cut -d = -f2)
    piauname=$(grep PIAUNAME 1.env | cut -d = -f2)
    piapass=$(grep PIAPASS 1.env | cut -d = -f2)
    pmstag=$(grep PMSTAG 1.env | cut -d = -f2)
    dldirectory=$(grep DLDIR 1.env | cut -d = -f2)
    tvdirectory=$(grep TVDIR 1.env | cut -d = -f2)
    miscdirectory=$(grep MISCDIR 1.env | cut -d = -f2)
    moviedirectory=$(grep MOVIEDIR 1.env | cut -d = -f2)
    musicdirectory=$(grep MUSICDIR 1.env | cut -d = -f2)
    # Echo back the media directioies, and other info to see if changes are needed
    printf "These are the Media Directory paths currently configured.\\n"
    printf "Your DOWNLOAD Directory is: %s \\n" "$dldirectory"
    printf "Your TV Directory is: %s \\n" "$tvdirectory"
    printf "Your MISC Directory is: %s \\n" "$miscdirectory"
    printf "Your MOVIE Directory is: %s \\n" "$moviedirectory"
    printf "Your MUSIC Directory is: %s \\n" "$musicdirectory"
    printf "\\n\\n"
    read  -r -p "Are these directiores still correct? (y/n) " diranswer "$(echo \n)"
    printf "\\n\\n"
    printf "Your PLEX Release Type is: %s" "$pmstag"
    printf "\\n\\n"
    read  -r -p "Do you need to change your PLEX Release Type? (y/n) " pmsanswer "$(echo \n)"
    printf "\\n\\n"
    read  -r -p "Do you need to change your PIA Credentials? (y/n) " piaanswer "$(echo \n)"
    # Now we need ".env" to exist again so we can stop just the Medaibox containers
    mv 1.env .env
    # Stop the current Mediabox stack
    printf "\\n\\nStopping Current Mediabox containers.\\n\\n"
    docker-compose stop
    # Make a datestampted copy of the existing .env file
    mv .env "$(date +"%Y-%m-%d_%H:%M").env"
fi

# Collect Server/User info:
# Get local Username
localuname=$(id -u -n)
# Get PUID
PUID=$(id -u "$localuname")
# Get GUID
PGID=$(id -g "$localuname")
# Get Docker Group Number
DOCKERGRP=$(grep docker /etc/group | cut -d ':' -f 3)
# Get Hostname
thishost=$(hostname)
# Get IP Address
locip=$(hostname -I | awk '{print $1}')
# Get Time Zone
time_zone=$(cat /etc/timezone)	
# Get CIDR Address
slash=$(ip a | grep "$locip" | cut -d ' ' -f6 | awk -F '/' '{print $2}')
lannet=$(awk -F"." '{print $1"."$2"."$3".0"}'<<<"$locip")/$slash

# Get Private Internet Access Info
if [ -z "$piaanswer" ] || [ "$piaanswer" == "y" ]; then
read -r -p "What is your PIA Username?: " piauname
read -r -s -p "What is your PIA Password? (Will not be echoed): " piapass
printf "\\n\\n"
fi

# Get info needed for PLEX Official image
if [ -z "$pmstag" ] || [ "$pmsanswer" == "y" ]; then
read -r -p "Which PLEX release do you want to run? By default 'public' will be used. (latest, public, plexpass): " pmstag
fi
# If not set - set PMS Tag to Public:
if [ -z "$pmstag" ]; then
   pmstag=public
fi

# Ask user if they already have TV, Movie, and Music directories
if [ -z "$diranswer" ]; then
printf "\\n\\n"
printf "If you already have TV - Movie - Music directories you want to use you can enter them next.\\n"
printf "If you want Mediabox to generate it's own directories just press enter to these questions."
printf "\\n\\n"
read -r -p "Where do you store your DOWNLOADS? (Please use full path - /path/to/downloads ): " dldirectory
read -r -p "Where do you store your TV media? (Please use full path - /path/to/tv ): " tvdirectory
read -r -p "Where do you store your MISC media? (Please use full path - /path/to/misc ): " miscdirectory
read -r -p "Where do you store your MOVIE media? (Please use full path - /path/to/movies ): " moviedirectory
read -r -p "Where do you store your MUSIC media? (Please use full path - /path/to/music ): " musicdirectory
fi
if [ "$diranswer" == "n" ]; then
read -r -p "Where do you store your DOWNLOADS? (Please use full path - /path/to/downloads ): " dldirectory
read -r -p "Where do you store your TV media? (Please use full path - /path/to/tv ): " tvdirectory
read -r -p "Where do you store your MISC media? (Please use full path - /path/to/misc ): " miscdirectory
read -r -p "Where do you store your MOVIE media? (Please use full path - /path/to/movies ): " moviedirectory
read -r -p "Where do you store your MUSIC media? (Please use full path - /path/to/music ): " musicdirectory
fi

# Create the directory structure
if [ -z "$dldirectory" ]; then
    mkdir -p content/completed
    mkdir -p content/incomplete
    dldirectory="$PWD/content"
else
  mkdir -p "$dldirectory"/completed
  mkdir -p "$dldirectory"/incomplete
fi
if [ -z "$tvdirectory" ]; then
    mkdir -p content/tv
    tvdirectory="$PWD/content/tv"
fi
if [ -z "$miscdirectory" ]; then
    mkdir -p content/misc
    miscdirectory="$PWD/content/misc"
fi
if [ -z "$moviedirectory" ]; then
    mkdir -p content/movies
    moviedirectory="$PWD/content/movies"
fi
if [ -z "$musicdirectory" ]; then
    mkdir -p content/music
    musicdirectory="$PWD/content/music"
fi

# Adjust for Container name changes
[ -d "sickrage/" ] && mv sickrage/ sickchill  # Switch from Sickrage to SickChill

mkdir -p couchpotato
mkdir -p delugevpn
mkdir -p delugevpn/config/openvpn
mkdir -p duplicati
mkdir -p duplicati/backups
mkdir -p emby
mkdir -p filebrowser
mkdir -p flaresolverr
mkdir -p glances
mkdir -p headphones
mkdir -p historical/env_files
mkdir -p homer
mkdir -p jackett
mkdir -p jellyfin
mkdir -p lidarr
mkdir -p metube
mkdir -p minio
mkdir -p nzbget
mkdir -p nzbhydra2
mkdir -p ombi
mkdir -p overseerr
mkdir -p "plex/Library/Application Support/Plex Media Server/Logs"
mkdir -p portainer
mkdir -p prowlarr
mkdir -p radarr
mkdir -p requestrr
mkdir -p sickchill
mkdir -p sonarr
mkdir -p speedtest
mkdir -p sqlitebrowser
mkdir -p tautulli
mkdir -p tdarr
mkdir -p tubesync

# Create menu - Select and Move the PIA VPN files
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
    # remove any existing ovpn, crt & pem files in the deluge config/ovpn
    rm delugevpn/config/openvpn/*.ovpn > /dev/null 2>&1
    rm delugevpn/config/openvpn/*.crt > /dev/null 2>&1
    rm delugevpn/config/openvpn/*.pem > /dev/null 2>&1
    # copy the selected ovpn file to deluge config/ovpn
    cp "$filename" delugevpn/config/openvpn/ > /dev/null 2>&1
    vpnremote=$(grep "remote" "$filename" | cut -d ' ' -f2  | head -1)
    # Adjust for the PIA OpenVPN ciphers fallback
    echo "cipher aes-256-gcm" >> delugevpn/config/openvpn/*.ovpn
    echo "ncp-disable" >> delugevpn/config/openvpn/*.ovpn
    # it'll ask for another unless we leave the loop
    break
done
# TODO - Add a default server selection if none selected ..
cp ovpn/*.crt delugevpn/config/openvpn/ > /dev/null 2>&1
cp ovpn/*.pem delugevpn/config/openvpn/ > /dev/null 2>&1

# Create the .env file
echo "Creating the .env file with the values we have gathered"
printf "\\n"
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
{
echo "LOCALUSER=$localuname"
echo "HOSTNAME=$thishost"
echo "IP_ADDRESS=$locip"
echo "PUID=$PUID"
echo "PGID=$PGID"
echo "DOCKERGRP=$DOCKERGRP"
echo "PWD=$PWD"
echo "DLDIR=$dldirectory"
echo "TVDIR=$tvdirectory"
echo "MISCDIR=$miscdirectory"
echo "MOVIEDIR=$moviedirectory"
echo "MUSICDIR=$musicdirectory"
echo "PIAUNAME=$piauname"
echo "PIAPASS=$piapass"
echo "CIDR_ADDRESS=$lannet"
echo "TZ=$time_zone"
echo "PMSTAG=$pmstag"
echo "VPN_REMOTE=$vpnremote"
} >> .env
echo ".env file creation complete"
printf "\\n\\n"

# Adjust for the Tautulli replacement of PlexPy
docker rm -f plexpy > /dev/null 2>&1
# Adjust for the Watchtower replacement of Ouroboros
docker rm -f ouroboros > /dev/null 2>&1
# Adjust for old uhttpd web container - Noted in issue #47
docker rm -f uhttpd > /dev/null 2>&1
[ -d "www/" ] && mv www/ historical/www/
# Adjust for removal of Muximux
docker rm -f muximux > /dev/null 2>&1
[ -d "muximux/" ] && mv muximux/ historical/muximux/
# Move back-up .env files
mv 20*.env historical/env_files/ > /dev/null 2>&1
mv historical/20*.env historical/env_files/ > /dev/null 2>&1
# Remove files after switch to using Prep folder
rm -f mediaboxconfig.php > /dev/null 2>&1
rm -f settings.ini.php > /dev/null 2>&1
rm -f prep/mediaboxconfig.php > /dev/null 2>&1
rm -f prep/settings.ini.php > /dev/null 2>&1
rm -f muximux/www/muximux/mediaboxconfig.php > /dev/null 2>&1
rm -f muximux/www/muximux/env.txt > /dev/null 2>&1

# Download & Launch the containers
echo "The containers will now be pulled and launched"
echo "This may take a while depending on your download speed"
read -r -p "Press any key to continue... " -n1 -s
printf "\\n\\n"
docker-compose up -d --remove-orphans
printf "\\n\\n"

# Configure the access to the Deluge Daemon
# The same credentials can be used for NZBGet's webui
if [ -z "$daemonun" ]; then
echo "You need to set a username and password for some of the programs - including."
echo "The Deluge daemon, NZBGet's API & web interface."
read -r -p "What would you like to use as the access username?: " daemonun
read -r -p "What would you like to use as the access password?: " daemonpass
printf "\\n\\n"
fi

# Finish up the config
printf "Configuring DelugeVPN, NZBGet, Muximux, and Permissions \\n"
printf "This may take a few minutes...\\n\\n"

# Configure DelugeVPN: Set Daemon access on, delete the core.conf~ file
while [ ! -f delugevpn/config/core.conf ]; do sleep 1; done
docker stop delugevpn > /dev/null 2>&1
rm delugevpn/config/core.conf~ > /dev/null 2>&1
perl -i -pe 's/"allow_remote": false,/"allow_remote": true,/g'  delugevpn/config/core.conf
perl -i -pe 's/"move_completed": false,/"move_completed": true,/g'  delugevpn/config/core.conf
docker start delugevpn > /dev/null 2>&1

# Configure FlareSolverr URL for Jackett
while [ ! -f jackett/Jackett/ServerConfig.json ]; do sleep 1; done
docker stop jackett > /dev/null 2>&1
perl -i -pe 's/"FlareSolverrUrl": ".*",/"FlareSolverrUrl": "http:\/\/'"$locip"':8191",/g' jackett/Jackett/ServerConfig.json
docker start jackett > /dev/null 2>&1

# Configure NZBGet
[ -d "content/nbzget" ] && mv content/nbzget/* content/ && rmdir content/nbzget
while [ ! -f nzbget/nzbget.conf ]; do sleep 1; done
docker stop nzbget > /dev/null 2>&1
perl -i -pe "s/ControlUsername=nzbget/ControlUsername=$daemonun/g"  nzbget/nzbget.conf
perl -i -pe "s/ControlPassword=tegbzn6789/ControlPassword=$daemonpass/g"  nzbget/nzbget.conf
perl -i -pe "s/{MainDir}\/intermediate/{MainDir}\/incomplete/g" nzbget/nzbget.conf
docker start nzbget > /dev/null 2>&1

# Push the Deluge Daemon and NZBGet Access info the to Auth file and the .env file
echo "$daemonun":"$daemonpass":10 >> ./delugevpn/config/auth
{
echo "CPDAEMONUN=$daemonun"
echo "CPDAEMONPASS=$daemonpass"
echo "NZBGETUN=$daemonun"
echo "NZBGETPASS=$daemonpass"
} >> .env

# Configure Homer settings and files
while [ ! -f homer/config.yml ]; do sleep 1; done
docker stop homer > /dev/null 2>&1
cp prep/config.yml homer/config.yml
cp prep/mediaboxconfig.html homer/mediaboxconfig.html
cp prep/portmap.html homer/portmap.html
cp prep/icons/* homer/icons/
sed '/^PIA/d' < .env > homer/env.txt # Pull PIA creds from the displayed .env file
perl -i -pe "s/thishost/$thishost/g" homer/config.yml
perl -i -pe "s/locip/$locip/g" homer/config.yml
perl -i -pe "s/locip/$locip/g" homer/mediaboxconfig.html
perl -i -pe "s/daemonun/$daemonun/g" homer/mediaboxconfig.html
perl -i -pe "s/daemonpass/$daemonpass/g" homer/mediaboxconfig.html
docker start homer > /dev/null 2>&1

# Configure Muximux settings and files
while [ ! -f muximux/www/muximux/settings.ini.php-example ]; do sleep 1; done
docker stop muximux > /dev/null 2>&1
cp prep/settings.ini.php muximux/www/muximux/settings.ini.php
sed '/^PIA/d' < .env > muximux/www/muximux/env.txt # Pull PIA creds from the displayed .env file
perl -i -pe "s/locip/$locip/g" muximux/www/muximux/settings.ini.php
docker start muximux > /dev/null 2>&1

# If PlexPy existed - copy plexpy.db to Tautulli
if [ -e plexpy/plexpy.db ]; then
    docker stop tautulli > /dev/null 2>&1
    mv tautulli/tautulli.db tautulli/tautulli.db.orig
    cp plexpy/plexpy.db tautulli/tautulli.db
    mv plexpy/plexpy.db plexpy/plexpy.db.moved
    docker start tautulli > /dev/null 2>&1
    mv plexpy/ historical/plexpy/
fi
if [ -e plexpy/plexpy.db.moved ]; then # Adjust for missed moves
    mv plexpy/ historical/plexpy/
fi

# Create Port Mapping file
for i in $(docker ps --format {{.Names}} | sort); do printf "\n === $i Ports ===\n" && docker port "$i"; done > homer/ports.txt

# Completion Message
printf "Setup Complete - Open a browser and go to: \\n\\n"
printf "http://%s \\nOR http://%s If you have appropriate DNS configured.\\n\\n" "$locip" "$thishost"
