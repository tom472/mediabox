# mediabox
Mediabox is meant to be an all Docker Container based media aggregator stack.

Components include:
  * Couchpotato
  * Deluge (using VPN)
  * PLEX
  * PlexPy
  * Ombi
  * Sickrage
  * Portainer
  * Minio
  
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

The options shown here to install the above packages may not make everyone happy (Yes - there will be curl -> bash used)
These are by far not the only methods to install these packages and if you are interested in finding other methods then feel free to do so, come on back here once the four packages above are installed.

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

**Please be prepared to supply the following details after you run Step 4.**

As the script runs you will be prompted for:

1. Your Private Internet Access credentials. (Username and Password)
2. The "Version" of Plex you want to run. (i.e. latest, public, plexpass)
3. PLEX - CLIAM_TOKEN - if you choose plexpass as your version. 
  * (This is Optional - Claim Token available by logging in here: https://www.plex.tv/claim)
4. The "style" of Portainer to use: (No Auth -OR- Latest)
  * Portainer with No Auth will not require a password for access and will automaticvally connect to the local Docker sock endpoint.
  * Portainer latest will; require a password, require a persistant volume map, and will need you to select the endpoint to manage.
5. Credentials for the Deluge daemon - this is needed for the CouchPotato container.

The script will complete and launch your mediabox containers.

---

# Normal Disclaimer

By using Mediabox - Not responsible if anything breaks.
Don't do anything bad
