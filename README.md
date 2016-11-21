# mediabox
Mediabox is meant to be an all Docker Container based media aggregator stack.

Components include:
  * Couchpotato
  * Deluge (using VPN)
  * PLEX
  * Sickrage
  * Portainer
  
# Prerequisites
**mediabox** has been tested to work on Ubuntu - Server and Desktop

You will need a VPN account from [Private internet Access](https://www.privateinternetaccess.com/)

(Please see [binhex's Github Repo](https://github.com/binhex/arch-delugevpn) if you want to use a different VPN)

Packages you will need installed and available are:
  * Git
  * Docker
  * Python-Pip
  * Docker-Compose
  
**PLEASE NOTE**

The options shown here to installs the above packages may not make everyone happy (Yes - there will be curl -> bash used)
These are by far not the only methods to install these packages and if you are interested in finding other methods then feel free to do so, come on back here once the four packages mentioned are installed.

### Installs:

Start off by making sure your system is currently up to date:

`$ sudo apt-get update && sudo apt-get -y upgrade`

**GIT:** `$ sudo apt-get install git`

**Docker:** `$ curl -fsSL https://get.docker.com/ | sh`

**Python-Pip:** `$ sudo apt-get install python-pip`

**Docker-Compose:** `$ sudo pip install docker-compose`

---

# Using mediabox

Once the prerequisites are all taken care of you can move forward with using mediabox.

1. In your terminal clone the mediabox repo: `$ git clone https://github.com/tom472/mediabox.git`
2. Change directory into mediabox: `$ cd mediabox/`
3. Make the mediabox.sh script executable: `$ chmod +x mediabox.sh`
4. Run the mediabox.sh script: `$ ./mediabox.sh`

As the script runs you will be prompted for your Private Internet Access credentials.

And credentials for the Deluge deamon - this is needed for the CouchPotato container.

The script will complete and launch your mediabox containers.
