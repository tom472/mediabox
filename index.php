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
code { 
  font-size: 90%;
  line-height: 1.2em;
  font-family: Monaco, Consolas, "Andale Mono", "DejaVu Sans Mono", monospace;

  display: inline; 
  color: #555555;
  padding: 1em 1em;
  background: #f4f4f4;
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
<h3>This page will help you manage your Mediabox server</h3>
<h3>Basic Information & Configuration</h3>  
The Couchpotato container is available at: locip:5050<br />
The DelugeVPN container is available at: locip:8112<br />
# A PRIVOXY proxy service is available at: locip:8118<br />
# The Deluge daemon port available at: locip:58846 - (For Couchpotato)<br />
The PLEX container is available at: locip:32400/web<br />
The Sickrage container is available at: locip:8081<br />
To manage and monitor your containers - Portainer is available at: locip:9000<br />

<h3>Manual Configuration steps:</h3>  
<b><u>Couchpotato:</u></b><br />
As you go through the Couchpotato Setup Wizard use these settings:<br />
<ol><li> Turn on Deluge -- Click the "slider" to the right of the Deluge option</ol>
<ul><li> Host: locip:58846<br />
<li> Username: daemonun<br />
<li> Password: daemonpass<br />
<li> Directory: [Leave Bliank]<br />
<li> Label: [Leave Blank]<br />
</ul>
<br />
After the Wizard is complete:<br />
Click on the "gear" icon and select "Settings"<br />
* Go to > Downloaders > Deluge > & click the "Test Deluge" button to verify the connection.<br />
* Go to > Renamer - and turn it on > Click the "slider" to the right<br />
# In the From field: /downloads<br />
# In the To field: /movies<br />
<br />
<br />
<p>Below are the variables in your .env file</p><br />
<div><pre><?php include('.env'); ?></pre></div>
</body>
</html>
