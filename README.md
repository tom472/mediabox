# mediabox
Mediabox is meant to be an all Docker Container based media aggregator stack.

Components include:
  * Couchpotato
  * Deluge (using VPN)
  * PLEX
  * Sickrage
  * Portainer
  
# Prerequisites
**mediabox** has been tested to work on Ubuntu

Packages you will need available are:
  * Git
  * Docker
  * Python-Pip
  * Docker-Compose
  
**PLEASE NOTE**

The methods shown here to installs the above packages may not make everyone happy (Yes - there will be curl -> bash used)

These are by far not the only methods to install these packages and if you are interested in finding other methods then feel free to do so, come on back here once the 4 packages mentioned are installed.

### Installs:

Start off by making sure your system is currently up to date:
```bash
sudo apt-get update && sudo apt-get -y upgrade
```

#### GIT
```bash
$ sudo apt-get install git
```

#### Docker
```bash
$ curl -fsSL https://get.docker.com/ | sh
```
#### Python-Pip
```bash
$ sudo apt-get install python-pip
```

#### Docker-Compose
```bash
$ sudo pip install docker-compose
```

