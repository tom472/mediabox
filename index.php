<!DOCTYPE html>
<html>
<head>
<style>
body {
  font-family: "Open Sans", sans-serif;
}
pre {
  font-size: 90%;
  line-height: 1.2em;
  font-family: "Courier 10 Pitch", Courier, monospace; 
  white-space: pre; 
  white-space: pre-wrap; 
  white-space: -moz-pre-wrap; 
  white-space: -o-pre-wrap; 

  height:1%;
  width: auto;
  display: inline-block;
  clear: both;
  color: #555555;
  padding: 1em 1em;
  margin: auto 10px auto 10px;
  background: #f4f4f4;
  border: solid 1px #e1e1e1
} 
p {
    border: 1px solid black;
    display: inline-block;
    padding: 5px
}
</style>
</head>
<body>
<h1>Welcome to Mediabox!</h1>
<h3><u>Basic Information & Configuration</u></h3>
The Couchpotato container is available at: locip:5050<br />
The DelugeVPN container is available at: locip:8112  -- Default Password is: deluge<br />
A PRIVOXY proxy service is available at: locip:8118<br />
The Deluge daemon port available at: locip:58846 - (For Couchpotato)<br />
The PLEX container is available at: locip:32400/web<br />
The Sickrage container is available at: locip:8081<br />
The Portainer container is available at: locip:9000<br />
The Muximux container is available at: locip<br />
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
<b><u>Sickrage</u></b>
<ul>
<li>Click on the settings "gear" icon
<li>Go to > General > Misc > Show root directories
<li>Click "New" - Select "tv"
<li>At the top right - Select Post Processing
<li>On the Post Processing Tab - Go to Post Processing Dir
<li>Click Browse > Select "downloads"
</ul>
<b><u>PLEX</u></b><br />
When adding libraries to PLEX use these settings:
<ul>
<li>Movies = /data/movies
<li>TV = /data/tvshows
</ul>
<h1>Mediabox Management Containers</h1>
<b><u>Portainer</u></b><br />
To help you manage your Mediabox Docker containers Portainer is available.<br />
Portainer is a Docker Management UI to help you work with the containers etc.
<br />
<b><u>MUXIMUX</u></b><br />
MUXIMUX is a lightweight way to manage your HTPC - This is the interface that you are using now.<br />
It provides a one-stop URL location that you can bookmark to be able to quickly access all of the individual HTPC components of Mediabox.<br />
By using the links located in the banner at the top of this page.<br />
<h1>Troubleshooting</h1>
If you are having issues with Mediabox or any of your continers please tak e look at the settings being used.<br />
Below are the variables in your .env file:
<div><pre><?php include('.env'); ?></pre></div>
</body>
</html>
