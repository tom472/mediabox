# mediabox
Mediabox is meant to be an all Docker Container based media aggregator stack.

Components include:
  * [Couchpotato movie library manager](https://couchpota.to/)
  * [Sickrage TV library manager](https://sickrage.github.io/)
  * [Deluge torrent client (using VPN)](http://deluge-torrent.org/)
  * [Radarr movie library manager](https://radarr.video/)
  * [Plex media server](https://www.plex.tv/)
  * [PlexPy media server monitor](https://jonnywong16.github.io/plexpy/)
  * [Ombi media assistant](http://www.ombi.io/)
  * [Portainer Docker Container manager](https://portainer.io/)
  * [Minio cloud storage](https://www.minio.io/)
  * [Watchtower automatic container updater](https://github.com/v2tec/watchtower)
  
# Prerequisites

  * [Ubuntu 16.04 LTS](https://www.ubuntu.com/)
  * [VPN account from Private internet Access](https://www.privateinternetaccess.com/pages/buy-vpn/Stevie) (Please see [binhex's Github Repo](https://github.com/binhex/arch-delugevpn) if you want to use a different VPN)
  * [Git](https://git-scm.com/)
  * [Docker](https://www.docker.com/)
  * [Python 2.7](https://www.python.org/)
  * [Python-Pip](https://pypi.python.org/pypi/pip)
  * [Docker-Compose](https://docs.docker.com/compose/)
  
**PLEASE NOTE**

For simplicity's sake (eg. automatic dependency management), the method used to install these packages is Ubuntu 16.04's default package manager, [APT](https://wiki.debian.org/Apt).  There are several other methods that work just as well, if not better (especially if you don't have superuser access on your system), so use whichever method you prefer.  Continue when you've successfully installed all packages listed.

### Installation:

(You'll need superuser access to run these commands successfully)

Start by updating and upgrading our current packages:

`$ sudo apt update && sudo apt full-upgrade`

Install the prerequisite packages:

`$ sudo apt install git python`

**Note** - Mediabox will install Docker CE as the default Docker version - if you skip this and run with older Docker versions you may have issues.

1. Uninstall old versions: `$ sudo apt-get remove docker docker-engine docker.io`
It’s OK if apt-get reports that none of these packages are installed.
2. Install Docker CE: `$ sudo curl -fsSL https://get.docker.com/ | sh`
3. Install Docker-Compose: `$ sudo curl -o /usr/local/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.16.1/docker-compose-$(uname -s)-$(uname -m)"`
4. Set the permissions: `$ sudo chmod +x /usr/local/bin/docker-compose`
5. Verify the installation: `$ docker-compose -v`

Add the current user to the docker group:

`$ sudo usermod -aG docker $USER`

Adjustment for the the DelugeVPN container

`$ sudo /sbin/modprobe iptable_mangle`

Reboot your machine manually, or using the command line:

`$ sudo reboot`

---

# Using mediabox

Once the prerequisites are all taken care of you can move forward with using mediabox.

1. Clone the mediabox repository: `$ git clone https://github.com/tom472/mediabox.git`
2. Change directory into mediabox: `$ cd mediabox/`
3. Make the mediabox.sh script executable: `$ chmod +x mediabox.sh`
4. Run the mediabox.sh script: `$ ./mediabox.sh`  **Read below for the script questions**

**Please be prepared to supply the following details after you run Step 4 above.**

As the script runs you will be prompted for:

1. Your Private Internet Access credentials
    * **username**
    * **password**

2. The version of Plex you want to run
    * **latest**
    * **public**
    * **plexpass**
    
Note: If you choose plexpass as your version you may optionally specify CLAIM_TOKEN - you can get your claim token by logging in at [plex.tv/claim](https://www.plex.tv/claim)

3. The "style" of Portainer to use
    *  **auth** (will require a password, require a persistent volume map, and will need you to select the endpoint to manage)
    *  **noauth** (will not require a password for access and will automatically connect to the local Docker sock endpoint)
    
4. Credentials for the Deluge daemon (this is needed for the CouchPotato container)
    * **username**
    * **password**

Upon completion, the script will launch your mediabox containers.

##### **mediabox** has been tested to work on Ubuntu 16.04 LTS - Server and Desktop

---

If you enjoy the project -- Fuel it with some caffeine :) 

[![Donate](https://img.shields.io/badge/Donate-SquareCash-brightgreen.svg)](https://cash.me/$TomMorgan)

---

# Normal Disclaimer

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# License

MIT License

Copyright (c) 2017 Tom Morgan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
