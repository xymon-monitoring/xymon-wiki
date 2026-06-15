# Port 1984

Historically uses port 1984 for data communication between the client and server.

This is not secured or encrypted.

# Cgi-bin xymoncgimsg.cgi

Alternatively the script xymoncgimsg.cgi can be used on a webserver like apache for communication between client and server.

The benefit is that the webserver can be configured with a ssl certificate so the communication is done via the https protocol.
Protection with username and password is also possible.

The encryption and username/password is not maintained within the xymon software but is the responsibility of the webserver hosting the xymoncgimsg.cgi script.

## Client support

The [XymonPSClient](../clients/windows-powershell/index.md) has built-in support for this.

For Unix (tested on AIX & Linux), wget and curl drop-in replacement scripts for the xymon binary are available [here](https://github.com/StefCoene/xymon/).
It's on the roadmap to include these scripts in the original release.