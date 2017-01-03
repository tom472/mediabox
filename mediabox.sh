#!/bin/bash

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

# CIDR - this assumes a 255.255.255.0 netmask - If your config is different use the custom CIDR line
lannet=`hostname -I | awk '{print $1}' | sed 's/\.[0-9]*$/.0\/24/'`
# Custom CIDR (comment out the line above if using this)
# Uncomment the line below and enter your CIDR info so the line looks like: lannet=xxx.xxx.xxx.0/24
#lannet=

# Get Private Internet Access Info
read -p "What is your PIA Username?: " piauname
read -s -p "What is your PIA Password? (Will not be echoed): " piapass
printf "\n\n"

# Get info needed for PLEX Official image
# read -p "What is your Timezone?: " tz
# Leaving Timezone out for now as we will be mountng /etc/localtime in the compose file
read -p "Which PLEX release do you want to run? By default Public will be used. (latest, public, plexpass): " pmstag
read -p "If you have PLEXPASS what is your Claim Token: (Optional) " pmstoken
# If not set - set PMS Tag to Public:
if [ -z "$pmstag" ]; then 
   pmstag=public 
fi

# Create the content file structure
`mkdir -p content/in_progress`
`mkdir -p content/downloads`
`mkdir -p content/movies`
`mkdir -p content/tv`

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
# printf "The IP address is: $locip\n"
# printf "The CIDR address is: $lannet\n"
# printf "The PIA Username is: $piauname\n"
# printf "The PIA Password is: $piapass\n"
# printf "The Hostname is: $thishost\n"
# printf "The Timezone is: $tz\n"
# printf "The Plex version is: $pmstag\n"
# printf "The Plexpass Claim token is: $pmstoken\n"

# Create the .env file
echo "Creating the .env file with the values we have gathered"
printf "\n"
echo "LOCALUSER=$localuname" >> .env
echo "HOSTNAME=$thishost" >> .env
echo "IP_ADDRESS=$locip" >> .env
echo "PUID=$PUID" >> .env
echo "PGID=$PGID" >> .env
echo "PIAUNAME=$piauname" >> .env
echo "PIAPASS=$piapass" >> .env
echo "CIDR_ADDRESS=$lannet" >> .env
# echo "TZ=$tz" >> .env
echo "PMSTAG=$pmstag" >> .env
echo "PMSTOKEN=$pmstoken" >> .env
echo ".env file creation complete"
printf "\n\n"

# Download & Launch the containers
echo "The containers will now be pulled and launched"
echo "This may take a while depending on your download speed"
read -p "Press any key to continue... " -n1 -s
printf "\n\n"
`docker-compose up -d`
printf "\n\n"

# Echo the configuration
printf " Container URLs and Ports \n"
printf "\n"
printf "The Couchpotato container is available at: $locip:5050\n"
printf "The DelugeVPN container is available at: $locip:8112\n"
printf " # A PRIVOXY proxy service is available at: $locip:8118\n"
printf " # The Deluge daemon port available at: $locip:58846 - (For Couchpotato)\n"
printf "The PLEX container is available at: $locip:32400/web\n"
printf "The Sickrage container is available at: $locip:8081\n"
printf "To manage and monitor your containers - Portainer is available at: $locip:9000\n"
printf "\n\n"

# Let's configure the access to the Deluge Deamon for CouchPotato
echo "CouchPotato requires access to the Deluge daemon port and needs credentials set."
read -p "What would you like to use as the daemon access username?: " daemonun
read -p "What would you like to use as the daemon access password?: " daemonpass
printf "\n\n"

# Access usernames & passwords
printf " Default Usernames & Passwords \n"
printf "\n"
printf "Deluge = The default password for the webui is - deluge\n"
printf "Deluge = The username for the daemon (needed in Couchpotato) is: $daemonun\n"
printf "Deluge = The password for the daemon (needed in Couchpotato) is: $daemonpass\n"

# Push the Deluge Deamon Access info the to Auth file
# printf "To complete the Deluge daemon access - copy and paste the line below to your terminal\n"
# printf "$ echo $daemonun:$daemonpass:10 >> ./delugevpn/config/auth"
`echo $daemonun:$daemonpass:10 >> ./delugevpn/config/auth`
# printf "\n"

# Configure the DelugeVPN file paths, Set Daemon access on, delete the core.conf~ file
`docker stop delugevpn > /dev/null 2>&1`
`rm delugevpn/config/core.conf~ > /dev/null 2>&1`
`sed -i 's/"allow_remote": false,/"allow_remote": true,/g'  delugevpn/config/core.conf`
`sed -i 's/"\/home\/nobody\/Incompletes"/"\/data\/in_progress"/g' delugevpn/config/core.conf`
`sed -i 's/"\/home\/nobody\/Completed"/"\/data\/downloads"/g' delugevpn/config/core.conf`
`docker start delugevpn > /dev/null 2>&1`

# Adjust the permissions on the content folder
`chmod -R 0777 content/`
