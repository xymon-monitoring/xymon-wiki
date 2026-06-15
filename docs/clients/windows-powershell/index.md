# Windows PowerShell Client aka XymonPSClient
This document is started as a copy-and-paste of the original XymonPSClient.doc

The Xymon PS (PowerShell) client runs as a Windows service. It is a PowerShell script that runs data collection routines approximately every 5 minutes by default. By default, every 72nd run (approximately every 6 hours) a “slow scan” is run which includes some routines that may take a little longer to run, for example, an update check.

# TCP or HTTP?
XymonPSClient supports sending data to the Xymon server in two ways – via TCP or via HTTP(S).

TCP is the usual way of connecting hosts to the Xymon server, using a normal TCP socket usually to port 1984. To use TCP, configure the <servers> element in xymonclient_config.xml and leave out <serverUrl> or make it blank (<serverUrl/>).

HTTP is an alternate method. It can be used if you have xymoncgimsg.cgi running on the web server on your Xymon server – see https://www.xymon.com/help/manpages/man8/xymoncgimsg.cgi.8.html. The web server running the CGI can be configured for SSL (i.e. HTTPS) and / or authentication – XymonPSClient supports basic authentication and SSL. If you require authentication, the <serverHttpUsername> and <serverHttpPassword> elements should be configured.

If you are using HTTP and transmitting over unsecure networks (e.g.  the internet), it is strongly recommended to enable SSL, authentication and disallow HTTP connections.

## serverHttpPassword encryption

If `<serverHttpPassword>` is set, the Xymon client will encrypt the password if it is not encrypted and remove the plain text password from the configuration file, overwriting with the encrypted password. The Xymon client will prefix the encrypted password with ‘{SecureString}’, so it is easy to tell if the client has attempted to encrypt the password or not.

This is done using the .NET SecureString functions, which means that the encryption is unique to the server and user. This means that once the password has been encrypted, you cannot use the same xymonclient_config.xml on another server. It also means that if you have been testing by running XymonPSClient from a command prompt, and this encrypts the password, when you run XymonPSClient as a service it will not be able to decrypt the password unless the service is running as the same user.

In both scenarios, replacing the encrypted password with the plain text password and re-starting Xymon will cause the password to be re-encypted.

# Configuration
The Xymon PS Client takes its configuration from two locations:

* [Local settings](local-settings.md): either registry or XML
* [Remote settings](remote-settings.md): returned from the Xymon server, configured in `client-local.cfg`

# [Installation and usage](installation.md)
