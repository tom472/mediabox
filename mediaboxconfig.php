<!DOCTYPE html>
<html>
<head>
<style>
body {
  font-family: "Open Sans", sans-serif;
}
</style>
</head>
<a href="https://cash.me/$TomMorgan" target="_blank"><img src="https://img.shields.io/badge/Donate-SquareCash-brightgreen.svg"></a><br />
<body>
<body style="background-color:lightblue;">
<h1>Welcome to Mediabox!</h1>
<h3><u>Basic Information & Configuration</u></h3>
<b><u>Notes:</u></b><br /> 
<li>Couchpotato and Radarr do the same thing = Movie Management</li>
<li>Sonarr and Sickrage do the same thing = TV Show Management</li>
-- Generally you will only want to choose/use one of each.<br />
<li>The <b>Minio</b> login is: minio / minio123.</li>
<br />
<h3><u>Manual Configuration steps:</u></h3>  
<b><u>Couchpotato:</u></b><br />
As you go through the Couchpotato Setup Wizard use these settings:<br />
<ul>
<li> Turn on Deluge -- Click the "slider" to the right of the Deluge option<br />
<li> Host: locip:58846<br />
<li> Username: daemonun<br />
<li> Password: daemonpass<br />
<li> Directory: [Leave Blank]<br />
<li> Label: [Leave Blank]<br />
</ul>
After the Wizard is complete:<br />
<ul>
<li> Click on the "gear" icon and select "Settings"<br />
<li> Go to > Downloaders > Deluge > & click the "Test Deluge" button to verify the connection.<br />
<li> Go to > Renamer - and turn it on > Click the "slider" to the right<br />
<li>In the From field: /downloads<br />
<li>In the To field: /movies<br />
</ul>
<br />
<b><u>Radarr:</u></b><br />
<ul>
<li>Click on the Settings icon<br />
<li>Clock on the Download Client Tab<br />
<li>Click on the + sign to add a download client<br />
<li>Under the "Torrent" section Select Deluge<br />
<li>Enter these settings:<br />
    * Name: Deluge<br />
    * Enable: Yes<br />
    * Host: locip<br />
    * Port: 8112<br />
    * Password: deluge (unless you have changed it)<br />
    * Category: blank<br />
    * Use SSL: No<br />
<li>Optional: Click on the media management tab and configure the renamer<br />
</ul>
<br />
<b><u>Sickrage:</u></b><br />
<ul>
<li>Click on the settings "gear" icon<br />
<li>Go to > General > Misc > Show root directories<br />
<li>Click "New" - Select "tv" -- Click "Save Changes"<br />
<li>At the top right - Select Post Processing<br />
<li>On the Post Processing Tab - Go to Post Processing Dir<br />
<li>Click Browse > Select "downloads"-- Click "Save Changes"<br />
<li>Click on the settings "gear" icon<br />
<li>Go to > Search Settings > Torrent Search (Tab)<br />
<li>Check the box for Enable Torrent Search Providers<br />
<li>For the "Send .torrent files to" dropdown select: Deluge (via WebUI)<br />
<li>For "Torrent host:port" use: http://locip:8112<br />
<li>For client password use: deluge (unless you have changed it)<br />
<li>After the settings are in Click the "Test Connection" button to see if it works -- Click "Save Changes"<br />  
</ul>
<br />
<b><u>Sonarr:</u></b><br />
<ul>
<li>Same instructions as Radarr<br />
</ul>
<br />
<b><u>PLEX:</u></b><br />
When adding libraries to PLEX use these settings:<br />
<ul>
<li>Movies = /data/movies<br />
<li>TV = /data/tvshows<br />
</ul>
<h3>Mediabox Management Containers</h3>
<b><u>Portainer:</u></b><br />
To help you manage your Mediabox Docker containers Portainer is available.<br />
Portainer is a Docker Management UI to help you work with the containers etc.<br />
If you notice the <b><u>Minio</u></b> container reporting as "Unhealthy" in Portainer from the commandline on your Mediabox server run this:<br />
<code>$ docker exec minio sed -i "s/404/403/g" /usr/bin/healthcheck.sh</code><br />
OR <br>
From the Minio console in Portainer (Select /bin/sh) run just this: <code>sed -i "s/404/403/g" /usr/bin/healthcheck.sh</code>
<br /><br />
<b><u>Watchtower:</u></b><br />
The Watchtower container monitors the all of the Mediabox containers and if there is an update to any container's base image it updates the container.<br />
Watchtower will detect the change, download the new image, gracefully stop the container(s), and re-launch them with the new image.<br />
<h1>Troubleshooting</h1>
If you are having issues with Mediabox or any of your continers please take look at the settings being used.<br />
Below are the variables in your .env file:
<pre>
<?php
echo file_get_contents("./env.txt");
?>
</pre>
If you enjoy the project -- Fuel it with some caffeine :)<br /><br />
<a href="https://cash.me/$TomMorgan" target="_blank"><img src="https://img.shields.io/badge/Donate-SquareCash-brightgreen.svg"></a><br />
<br />
</body>
</html>
