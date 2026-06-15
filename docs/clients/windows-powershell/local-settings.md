# Local settings
Local settings are non-frequently changing items such as the address of FQDN of the Xymon server.

In the original Xymon PS client, the local settings were stored in the registry and could only be modified via RegEdit or the client script itself.

In XymonPSClient, the registry settings can still be used but if a xymonclient_config.xml is present in the same directory as xymonclient.ps1, the XML file will be used in preference to the registry. Using an XML file makes the settings more transparent and easier to amend if necessary.

If you wish to use registry settings, you should not supply an XML file. If you supply an XML file, any registry configuration will be ignored. Registry settings are only supported for backwards compatibility.

The XML file is a standard XML file comprising XML elements. An example is shown below:
```
<XymonSettings>
  <servers>xymonserver.domain.com</servers>
  <clientlogfile>c:\xymonclient.log</clientlogfile>
  <clientconfigfile>c:\program files\xymon\clientconfig.cfg</clientconfigfile>
  <clientfqdn>0</clientfqdn>
  <clientlower>1</clientlower>
  <clientremotecfgexec>1</clientremotecfgexec>
</XymonSettings>
```

If a setting is not supplied in the config file or registry, then the default value is used. The minimum configuration would be to supply just the `<servers>` element in `<XymonSettings>` elements and use defaults for all other settings.

| Option | Default | Description |
|--------|---------|-------------|
| clientname | (none) | Override the client name reported to the server. By default, the client name is obtained from the netoworking properties of the OS, or the COMPUTERNAME environment variable. If this setting has a value, it will override any value obtained from the OS.|
| servers | (none) | IP address(es) or FQDN(s) of Xymon servers to send data to, separated by space ‘ ‘ if multiple.<br> See “TCP or HTTP?” below |
| serverUrl | (none) | Url of Xymon server to send data to  requires server to be running xymoncgimsg.cgi<br> See “TCP or HTTP?” below |
| serverHttpUsername | (none) | If using HTTP, username to use for authenticating to the Xymon web server (optional).<br> See “TCP or HTTP?” below |
| serverHttpPassword | (none) | If using HTTP, password to use for authenticating to the Xymon web server (optional).<br> If populated, this value will be encrypted automatically on the first run.<br> See “TCP or HTTP?” below |
| serverHttpTimeoutMs | 100000 | If using HTTP, timeout in milliseconds for the HTTP request/response. |
| clientlogfile | %TEMP%\xymonclient.log | File to which xymon client messages are logged to. This file is overwritten on every data collection. |
| clientconfigfile | %TEMP%\xymonconfig.cfg | File to which the remote config from the Xymon server is cached. If you’re not using the remote config, you can put config directives in this file. |
| clientlogpath | The path used for clientlogfile | Path where the client will write a log file containing the data sent to the server. This file (xymon-lastcollect.txt) is overwritten on every collection. |
| clientlogretain | 0 | If greater than 0, the client will retain this many log files (xymonclient.log and xymon-lastcollect.txt), and will rotate them automatically. |
| clientsoftware | powershell | Used to override the software name reported to Xymon. Can be set to bbwin to report that the client software is bbwin. |
| clientclass | powershell | Used to override the class reported to Xymon. |
| clientfqdn | 1 | 0 = the client does not attempt to resolve the client name to an FQDN<br> 1 = the client attempts to resolve the client name to an FQDN<br> e.g. if the client host name is client1, 0 would return just client1 as the client name. 1 would return client1.domain.com. " | clientlower | 1 | 0 = the case of the client name is not changed<br>1 = the client name is forced to lower case|
| clientremotecfgexec | 0 | 0 = do not parse and use the config returned by the server<br> 1 = parse and use the config returned by the server. This will cause the file specified by clientconfigfile to be overwritten|
| loopinterval | 300 | The client will report data to the server every <loopinterval> seconds.
| slowscanrate | 72 | Every so many collections, the client will perform some extra tests and potentially check for updates. This parameter controls how often it happens  by default, 72 * 300 seconds (loopinterval) = 6 hours
| maxlogage | 60 | Minutes age for event log reporting
| Maxevents | 5000 | The maximum number of event log messages that can be returned in one data collection, per log
| reportevt | 1 | Whether to scan and report event log <br> 0 = no<br> 1 = yes|
| wanteddisks | 3 | Numeric values, space separated. Default is 3 (fixed disks only).<br> 2 = Removable (e.g. USB)<br> 3 = Fixed (local disks)<br> 4 = Remote (network shares)<br> 5 = CD<br> 6 = RAM disk<br> 99 = unmounted volumes|
| EnableWin32_Product | 0 | 0 = do not use Win32_Product <br> 1 = use Win32_Product<br> This item has been removed as use of Win32_Product is not recommended by Microsoft (see http://support.microsoft.com/kb/974524)|
| EnableWin32_QuickFixEngineering | 0 | 0 = do not use  Win32_QuickFixEngineering<br> 1 = use Win32_QuickFixEngineering<br> This is disabled by default to minimise the number of WMI calls used. If enabled, Win32_QuickFixEngineering is called on slow scans.|
| EnableWMISections | 0 | 0 = disable additional WMI data<br> 1 = enable additional WMI data<br> This is disabled by default to minimise the number of WMI calls used. If enabled, extra WMI calls and data is returned for OS, BIOS, Processor, Memory, Disk.|
| EnableIISSection | 1 | 0 = disable collecting IIS site data<br> 1 = enable collecting IIS site data<br> Used to return some information about sites IIS is serving
| ClientProcessPriority | Normal | Possible values Normal, Idle, High, RealTime, BelowNormal, AboveNormal.<br> Can be used to raise or lower the process priority of the powershell process running the client. |
| servergiflocation | /xymon/gifs | The location of server gifs such as red.gif, yellow.gif, green.gif. Used for sending custom data to the server. Note that this can also be specified by the server in the client-local.cfg and that any setting sent by the server will override the local setting.|
| externalscriptlocation | `<installation dir>\ext` | The location for external scripts|
| externaldatalocation | `<installation dir>\tmp` | The location for external data. External processes can place BBWin format data files in this location and the XymonPS client will pick them up and send them to the server as ‘status’ messages.|
| localdatalocation | `<installation dir>\local` | The location for ‘local’ data.<br> External processes can place data files in this location and the XymonPS client will pick them up and include them in the core ‘client’ message.|
| clientbbwinmembug | 1 (compatible with BBWin) | Set to 1 to maintain compatibility with BBWin. Setting to 0 swaps the values for ‘page’ and ‘virtual’  this is the correct order but not how BBWin did it.<br> XymonAcceptUTF8 | 0 | 0 = send client messages to Xymon using “original” ASCII encoding (the default)  does not strip diacritic or multibyte characters<br> 1 = send client messages to Xymon using UTF8 encoding<br> Use with caution, enabling UTF8 may cause unexpected behaviour.<br> 2 = send client messages using “pure” ASCII encoding  will filter/convert diacritics but may take extra CPU/processing time|
| EnableDiskPart | 0 | 0 = do not run diskpart commands<br> 1 = run diskpart commands to determine and report whether this server has clustered volumes  note, can cause memory leaks in Microsoft Virtual Disk service|