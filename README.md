# Mediabox

Mediabox is an all Docker Container based media aggregator stack.

Components include:

*   [Couchpotato movie library manager](https://couchpota.to/)
*   [Deluge torrent client (using VPN)](http://deluge-torrent.org/)
*   [Duplicati Backup Software](https://www.duplicati.com/)
*   [Headphones](https://github.com/linuxserver/docker-headphones)
*   [Jackett Tracker API and Proxy](https://github.com/Jackett/Jackett)
*   [Jellyfin Free Software Media System](https://github.com/jellyfin/jellyfin)
*   [Lidarr Music collection manager](https://lidarr.audio/)
*   [Minio cloud storage](https://www.minio.io/)
*   [Muximux Web based HTPC manager](https://github.com/mescon/Muximux)
*   [NetData System Monitoring](https://github.com/netdata/netdata)
*   [NZBGet Usenet Downloader](https://nzbget.net/)  
*   [NZBHydra2 Meta Search](https://github.com/theotherp/nzbhydra2)  
*   [Ombi media assistant](http://www.ombi.io/)
*   [Plex media server](https://www.plex.tv/)
*   [Portainer Docker Container manager](https://portainer.io/)
*   [Radarr movie library manager](https://radarr.video/)
*   [SABnzbd Usenet download tool](https://github.com/sabnzbd/sabnzbd)
*   [SickChill TV library manager](https://github.com/SickChill/SickChill)
*   [Sonarr TV library manager](https://sonarr.tv/)
*   [Tautulli Plex Media Server monitor](https://github.com/tautulli/tautulli)
*   [Watchtower Automatic container updater](https://github.com/containrrr/watchtower)

## Prerequisites

*   [Ubuntu 16.04 LTS](https://www.ubuntu.com/) Or [Ubuntu 18.04 LTS](https://www.ubuntu.com/)
*   [VPN account from Private internet Access](https://www.privateinternetaccess.com/) (Please see [binhex's Github Repo](https://github.com/binhex/arch-delugevpn) if you want to use a different VPN)
*   [Git](https://git-scm.com/)
*   [Docker](https://www.docker.com/)
*   [Docker-Compose](https://docs.docker.com/compose/)

### **PLEASE NOTE**

For simplicity's sake (eg. automatic dependency management), the method used to install these packages is Ubuntu's default package manager, [APT](https://wiki.debian.org/Apt).  There are several other methods that work just as well, if not better (especially if you don't have superuser access on your system), so use whichever method you prefer.  Continue when you've successfully installed all packages listed.

### Installation

(You'll need superuser access to run these commands successfully)

Start by updating and upgrading our current packages:

`$ sudo apt update && sudo apt full-upgrade`

Install the prerequisite packages:

`$ sudo apt install curl git bridge-utils`

**Note** - Mediabox uses Docker CE as the default Docker version - if you skip this and run with older/other Docker versions you may have issues.

1.  Uninstall old versions - It’s OK if apt and/or snap report that none of these packages are installed.  
    `$ sudo apt remove docker docker-engine docker.io containerd runc`  
    `$ sudo snap remove docker`  

2.  Install Docker CE:  
    `$ curl -fsSL https://get.docker.com -o get-docker.sh`  
    `$ sudo sh get-docker.sh`  

3.  Install Docker-Compose:  

    ```bash
    sudo curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "browser_download_url" | grep -m1 `uname -s`-`uname -m` | cut -d '"' -f4 | xargs sudo curl -L -o /usr/local/bin/docker-compose
    ```

4.  Set the permissions: `$ sudo chmod +x /usr/local/bin/docker-compose`  

5.  Verify the Docker Compose installation: `$ docker-compose -v`  

Add the current user to the docker group:

`$ sudo usermod -aG docker $USER`

Adjustments for the the DelugeVPN container

`$ sudo /sbin/modprobe iptable_mangle`

`$ sudo bash -c "echo iptable_mangle >> /etc/modules"`

Reboot your machine manually, or using the command line:

`$ sudo reboot`

## Using mediabox

Once the prerequisites are all taken care of you can move forward with using mediabox.

1.  Clone the mediabox repository: `$ git clone https://github.com/tom472/mediabox.git`

2.  Change directory into mediabox: `$ cd mediabox/`

3.  Run the mediabox.sh script: `$ ./mediabox.sh`  (**See below for the script questions**)

4.  To upgrade Mediabox at anytime, re-run the mediabox script: `$ ./mediabox.sh`

### Please be prepared to supply the following details after you run Step 3 above

As the script runs you will be prompted for:

1.  Your Private Internet Access credentials
    *   **username**
    *   **password**

2.  The version of Plex you want to run
    *   **latest**
    *   **public**
    *   **plexpass**

    Note: If you choose plexpass as your version you may optionally specify CLAIM_TOKEN - you can get your claim token by logging in at [plex.tv/claim](https://www.plex.tv/claim)

3.  Portainer has been switched to the **CE** branch
    *   **A Password** will now be required - the password can be set at initial login to Portiner.  
    *   **Initial Username** The initial username for Portainer is **admin**  

4.  Credentials for the NBZGet interface and the Deluge daemon which needed for the CouchPotato container.
    *   **username**
    *   **password**

Upon completion, the script will launch your mediabox containers.

### **Mediabox has been tested to work on Ubuntu 18.04 LTS / 20.04 LTS - Server and Desktop**

**Thanks go out to:**

[@kspillane](https://github.com/kspillane) - Jumped right in and is providing helpful commits / PRs

[@mnkhouri](https://github.com/mnkhouri) - provided a large amount of code clean-up.

[@danipolo](https://github.com/danipolo) for the bridge-utils tip

[binhex](https://github.com/binhex)

[LinuxServer.io](https://github.com/linuxserver)

[Docker](https://github.com/docker)

[Portainer.io](https://github.com/portainer)

---

If you enjoy the project -- Fuel it with some caffeine :)

[![Donate](https://img.shields.io/badge/Donate-SquareCash-brightgreen.svg)](https://cash.me/$TomMorgan)

---

## Disclaimer

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## License

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
