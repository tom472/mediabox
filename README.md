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

  * Ubuntu 16.04 LTS
  * VPN account from [Private internet Access](https://www.privateinternetaccess.com/pages/buy-vpn/Stevie) (Please see [binhex's Github Repo](https://github.com/binhex/arch-delugevpn) if you want to use a different VPN)
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

`$ sudo apt-get update && sudo apt full-upgrade`

Install all prerequisite packages and their dependencies:

`$ sudo apt install git docker python python-pip docker-compose`

---

# Using mediabox

Once the prerequisites are all taken care of you can move forward with using mediabox.

1. Clone the mediabox repository: `$ git clone https://github.com/tom472/mediabox.git`
2. Change directory into mediabox: `$ cd mediabox/`
3. Make the mediabox.sh script executable: `$ chmod +x mediabox.sh`
4. Run the mediabox.sh script: `$ ./mediabox.sh`

**Please be prepared to supply the following details after you run Step 4.**

As the script runs you will be prompted for:

1. Your Private Internet Access credentials
    * **username**
    * **password**
2. The version of Plex you want to run
    * **latest**, or
    * **public**, or
    * **plexpass**
3. If you choose plexpass as your version you may optionally specify CLAIM_TOKEN - you can get your claim token by logging in at [plex.tv/claim](https://www.plex.tv/claim)
4. The "style" of Portainer to use:
    * **auth** (will require a password, require a persistent volume map, and will need you to select the endpoint to manage), or
    * **noauth** (will not require a password for access and will automatically connect to the local Docker sock endpoint)
5. Credentials for the Deluge daemon - this is needed for the CouchPotato container.

The script will complete and launch your mediabox containers.

---

##### **mediabox** has been tested to work on Ubuntu 16.04 LTS - Server and Desktop


# Normal Disclaimer

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
