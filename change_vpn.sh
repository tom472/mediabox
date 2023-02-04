#!/bin/bash

# Check that script was run not as root or with sudo
if [ "$EUID" -eq 0 ]
  then echo "Please do not run this script as root or using sudo"
  exit
fi

# set -x

# Stop the current running DelugeVPN container
docker stop delugevpn > /dev/null 2>&1

# Clear current VPN from the .env
sed '/^VPN_REMOTE/d' < .env > tmp.env
mv tmp.env .env

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
    # echo "ncp-disable" >> delugevpn/config/openvpn/*.ovpn -- possibly not needed anymore
    # it'll ask for another unless we leave the loop
    break
done
# TODO - Add a default server selection if none selected ..
cp ovpn/*.crt delugevpn/config/openvpn/ > /dev/null 2>&1
cp ovpn/*.pem delugevpn/config/openvpn/ > /dev/null 2>&1

# Add New VPN Endpoint to the .env anf .env.txt
echo "VPN_REMOTE=$vpnremote" >> .env
sed '/^PIA/d' < .env > homer/env.txt

# Restart the DelugeVPN Container
docker start delugevpn > /dev/null 2>&1
