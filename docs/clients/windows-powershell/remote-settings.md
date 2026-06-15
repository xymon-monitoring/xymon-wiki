# Remote settings
The configuration items in this section are additional to the standard configuration items accepted by the Xymon client on other operating systems. These standard items are documented in the `client-local.cfg` man page or via the xymon.com website (https://www.xymon.com/help/manpages/man5/client-local.cfg.5.html).

## eventlogswanted & eventlog

These two directives allow the monitoring of event log data.

By default, data from the last 60 minutes is returned. This can be overridden by using the `<maxlogage>` element in xymonclient_config.xml.

Both directives are optional – if eventlogswanted is not specified, by default data from the Application, System and Security logs will be returned up to a maximum length of 1024 bytes total.

eventlog entries allow filtering out or including certain events.

Only one eventlogswanted statement can be processed. If you are using config merging and you have multiple eventlogswanted statements, you can set a priority on the statements – the statement with the highest priority will be the one processed.

## eventlogswanted

`eventlogswanted:PRIORITY:LIST_OF_EVENT_LOGS:MAX_SIZE:REQUIRED_LEVELS`

* PRIORITY – optional – used to specify which eventlogswanted statement is used, in case config merging means multiple eventlogswanted statements appear. The statement with the highest priority will be used. If omitted, priority for the statement will be zero.
* LIST_OF_EVENT_LOGS – a comma delimited list of event logs to retrieve data from; can use wildcards (* = match any character)
* MAX_SIZE – the maximum amount of data to be returned 
* REQUIRED_LEVELS – optional – the levels that should be returned, comma separated. Allowed values: Information, Warning, Critical, Error, Verbose. By default, all are returned.

**Examples**
* `eventlogswanted:100:Application,System:1000:Warning,Critical`
* `eventlogswanted:System:1000:Warning,Critical,Error`

If config merging resulted in the above two eventlogswanted statements, the first would be used as it has a priority of 100.

## eventlog

`eventlog:EVENT_LOG`

* EVENT_LOG – the event log this section refers to

The eventlog directive works in one of two ways:
* Exclude mode: including all events except specified – use ignore
* Include mode: ignore all events except specified – use include

The directive should be followed by either one or more ignore directives or one or more include directives. 

Include mode takes priority - if there are any “include” entries, include mode will be used. All ignore entries will be disregarded. 

Ignore / Include configure which event log entries should be ignored or included. If the event log provider or message match an ignore or include pattern, the event log entry will filtered appropriately.

`ignore PATTERN`: PATTERN – a regular expression to ignore

`include PATTERN`: PATTERN – a regular expression to include

## log

`log:FILENAME:SIZE:POSITIONS`

Same as standard client-local.cfg, except ignore and trigger statements are not supported. Used to return entries from log files from various applications.

* FILENAME – filename of the log. Wildcards are supported in the FILENAME field. Backticks are not supported.
* SIZE – the maximum amount of data to be returned.
* POSITIONS (optional) – the client returns the logfile and then saves the position. This is used to detect growth. By default, 6 positions are saved and the oldest saved position is removed every time the client collects data (by default, every 5 minutes). Therefore, unless new data is appended, nothing will be returned after 30 minutes. This parameter allows you to adjust the number of saved positions to extend this period (e.g. 288 = 24 hours).

## dir

`dir:DIRECTORYNAME`

Same as standard client-local.cfg – used to watch the size of a directory.

* DIRECTORYNAME – directory to monitor. Backticks are not supported.

## file

`file:FILENAME`

Same as standard client-local.cfg. Used to watch the meta-data of a file: owner, group, size, permissions.

Note that unlike the standard client, file hashing is not supported.

* FILENAME – filename to report on

## dirsize

`dirsize:DIRECTORYNAME:OPERATOR:SIZE:COLOUR`

Used to monitor the size of a directory or file

* DIRECTORYNAME – directory or filename to monitor
* OPERATOR – gt / lt / eq – an operator to apply to the SIZE parameter
* SIZE – the size (in bytes) to use with operator. The actual directory/file size is compared to this SIZE and controls the colour returned if the condition is met.
* COLOUR – the colour (red/yellow/green) to be returned if the condition is met

For example, if you want a red status when c:\temp rises above 100000 bytes:

`dirsize:c:\temp:gt:100000:red`

dirsize can also be used to check that a file exists or check that a file or directory does not exist. When an item does not exist, the size is set to -1. Therefore:

`dirsize:c:\temp\should-not-exist.txt:gt:0:red`

will give a red alert if the file `c:\temp\should-not-exist.txt` does exist, and:

`dirsize:c\temp\should-exist.txt:lt:0:red`

will give a red alert if the file `c\temp\should-exist.txt` does not exist.

## dirtime

`dirtime:DIRECTORYNAME:UNUSED:OPERATOR:MINUTES:COLOUR`

Used to monitor whether the last modification time of a directory or file has changed. The last modification time of the item is subtracted from the current date/time and a specified status is sent if the number of minutes is greater than, less than or equal to the minutes specified.

* DIRECTORYNAME – directory or filename to monitor
* UNUSED – not used (retained for compatibility) – can be left blank
* OPERATOR – gt / lt / eq – an operator to apply to the MINUTES parameter
* MINUTES – the number of minutes to use with operator. Used to compare with the actual value and control the colour returned.
* COLOUR – the colour (red/yellow/green) to be returned if the condition is met

For example, if you expect the directory c:\temp to receive regular updates, you may want to send a red status if no files have been written for 30 minutes:

`dirtime:c:\temp::gt:30:red`

This would send a red status if the last modification date of c:\temp was more than 30 minutes ago.

## servicecheck

`servicecheck:SERVICENAME:DURATION`

Check a specified Windows Service is running and attempt to start it if not.

* SERVICENAME – name of the service to check. Should be the name from the Name field when you execute get-service from a Powershell prompt – not the name from the Services control panel
* DURATION – how long in seconds a service should not be running before the client will attempt to restart it

For each servicecheck directive, the client will track the last time it saw the service running. If the service stops, it will be restarted after DURATION seconds – bearing in mind that by default, the client only performs data collections every 5 minutes, so the restart would be the next 5 minute boundary after DURATION seconds.

## noservicecheck

`noservicecheck:SERVICENAME:DAYOFWEEK:STARTHOUR:DURATION`

Checks if a specified Windows Service servicecheck exists and suppresses it during the specified maintenance window. Window can span multiple days, as specified by Duration, but would terminate if script is restarted after initiation day/hour.

* SERVICENAME – name of the service to check for a ‘servicecheck’ statement. 
* DAYOFWEEK – numeric day of the week, where Sunday = 0, Monday = 1, etc.
* STARTHOUR – hour to start the maintenance window, 0 for midnight up to 23 (24 hour clock)
* DURATION – how long in hours the maintenance window should last

Examples:

`servicecheck:Sophos Message Router:10`

`noservicecheck:Sophos Message Router:0:5:1 `: no restart starting first scan after Sunday 5AM to first scan after 6AM

## clientversion

`clientversion:VERSION:UPDATE_LOCATION:HASH:HASHVALUE`

Used to specify the version of the script the client should be running. If the client is running a lower version, it will attempt to retrieve the correct version from the location given and restart. If the client version is equal to or greater than the specified version, no action is taken.
Update checks run on “slow scan” executions – by default, approximately every 6 hours.

* VERSION – the version number the client should be running.
* UPDATE_LOCATION – the location where the client can copy the newer version of the script from. This can be an UNC path (\\SERVER\share\), or a http, https or bb url. Should not contain a filename. If you have not disabled the download command on the Xymon server, you can use bb:// urls (bb://path/on/server) which will copy the script directly from the Xymon server’s download directory.
* HASH – optional – possible values MD5, SHA1 or SHA256 - specify a hashing algorithm to check the update file matches the expected HASHVALUE
* HASHVALUE – optional (required if HASH specified) – specify a hash value to compare to the calculated hash value of the download update

The client expects to be able to download or copy a file `xymonclient_<version>.ps1` from the update location (e.g. `xymonclient_1.95.ps1`). If the file cannot be downloaded or copied, the current version of the script will continue running.

If you are using the http(s) option and your web server returns an unusual 404 page or random garbage, and you do not use the hashing option, the client may be updated to whatever your web server returns.

If the hash options are used, any update (whether from UNC path or http(s)) will have a hash value calculated and this will be compared to the HASHVALUE specified. If the values match, the update will be applied, otherwise, the update will be rejected. It is therefore recommended that you use these options from version 2.05 onwards! You should calculate the hash value using md5sum, sha1sum, sha256sum or similar to match the HASH algorithm you specify.

**Examples**

`clientversion:2.01:\\server1\XymonPS\`

Minimum client version should be 2.01 and updates can be downloaded from the share [\\server1\XymonPS](file://server1/XymonPS)

`clientversion:2.1:http://server1/XymonPS:MD5:6e8a1dd4e0bdc1ff97955f8ea6cc7baa`

Minimum client version should be 2.1 and updates can be downloaded from http://server1/XymonPS. The update should be hashed using MD5 and if the calculated value does not match 6e8a1dd4e0bdc1ff97955f8ea6cc7baa, then the update will be rejected (this is an example hash value only).

`clientversion:2.21:bb://XymonPS:SHA1:829bc631cd428c55c4673c00242db81fe7c4fb37`

Minimum client version should be 2.21 and updates can be downloaded from the XymonPS sub directory of the download directory on the Xymon server. The update should be hashed using SHA1 and if the calculated value does not match 829bc631cd428c55c4673c00242db81fe7c4fb37, then the update will be rejected (this is an example hash value only).

## servergifs

`servergifs:GIFS_LOCATION`

Specify a location for server gifs – used when sending custom status messages.

This is useful when the default location has been overridden on the Xymon server. It’s used to point to the red.gif / yellow.gif / green.gif images when custom status screens are being sent to the server.

* GIFS_LOCATION – the location on the server for server gifs, must be http[s] accessible. Should end in a slash (/).

**Example**

`servergifs:/site/London/`

## terminalservicessessions

can be shortened to tssessions

`terminalservicessessions:YELLOW_STATUS:RED_STATUS`

`tssessions:YELLOW_STATUS:RED_STATUS`

Monitors the number of remote desktop / terminal services sessions available on a server

* YELLOW_STATUS – when the number of free sessions is less than or equal to this value, a yellow status is returned
* RED_STATUS – when the number of free sessions is less than or equal to this value, a red status is returned

## adreplicationcheck

Check the status of Active Directory replication – only makes sense to use this directive on domain controllers. Uses the repadmin tool (which should be present on domain controllers). Sends a red status if any replications show as failed (i.e. ‘Last Failure Time’ is more recent than ‘Last Success Time’).

## ifstat

`ifstat:<LIST_OF_IP_CLASSES>`

By default, the client will report on IPv4 addresses in the [ifstat] section. This directive can be used to report on just IPv6 or both IPv4 and IPv6.

* LIST_OF_IP_CLASSES – ip classes to report on, comma separated. Supported classes: ‘IPv4’ or ‘IPv6’ (not case sensitive)

**Examples**

Just report on IPv6 addresses:

`ifstat:ipv6`

Report on IPv4 and IPv6 addresses:

`ifstat:ipv4,ipv6`

## ports

`ports:OPTION`

Used to limit the ports reported to just listening ports. By default, the client will report all ports (netstat -an); setting the option can be used to limit to just listening ports (equivalent to netstat -an | findstr LISTENING).

* OPTION – supported value ‘listenonly’. Any other values / text will be ignored.

If ports is not specified in client-local.cfg, or any option other than ‘listenonly’ is specified, then all ports will be reported. If ‘ports:listenonly’ is specified, only listening ports will be reported.

**Examples**

Report only listening ports:

`ports:listenonly`

Report all ports:

`ports:all` (or omit ports statement)

## processruntime

can be shortened to procruntime

`processruntime:PROCESS_NAME:YELLOW_STATUS:RED_STATUS`

`procruntime:PROCESS_NAME:YELLOW_STATUS:RED_STATUS`

Will raise an alert if the named process has been running for a specified number of minutes. For example, if you have a process that should normally take 10 minutes but 30 minutes is abnormal, you can use this test to check and alert when the process takes more than 10 minutes to run.
The Xymon PS client uses data from Windows to find out the start time of each process. From this, it can calculate how long a process has been “alive” for, the elapsed time. This data is then used for this alert and is shown on the procs page.
* PROCESS_NAME – then process to alert on. This should match the name of the process as seen on the cpu page. Service names can also be used, prefixed with SVC: as seen on the cpu page.
* YELLOW_STATUS – number of minutes after which a yellow alert will be raised.
* RED_STATUS – number of minutes after which a red alert will be raised.

**Examples**

Raise a yellow alert if an importer process is found that has been running for 20 minutes. Red if it has been running for 60 minutes:

`processruntime:importer:20:60`

Raise a yellow alert if the importer service has been running for 30 minutes. Red if it has been running for 60 minutes:

`procruntime:SVC:importer:30:60`

## repeattest

`repeattest:<TEST>:<DESTINATION TEST>`

`trigger:<ALERTCOLOUR>:<REGEX>`

repeattest allows you to repeat the results of an existing test as a standalone status message to the server under a different test name. Both will then be shown on the dashboard and this allows you to split alerts to different destination. For example, you may have an application team you want alerts for certain services to go to, and a different infrastructure team for other service alerts.

You can optionally specify one or more ‘trigger’ statements that will control what colour is sent to the server. This allows you to control alerts based on the content of the test.

repeattest parameters:

* TEST – the test to repeat (e.g. disk, cpu, svcs) – this must be the name of a section in the data sent to Xymon 
* DESTINATION TEST – the test name the repeated data will be sent as. 

trigger parameters:
* ALERTCOLOUR – the colour of alert to raise (red, yellow, green)
* REGEX – the regular expression used to detect a condition for which an ALERTCOLOUR alert should be raised

**Examples**

Repeat the services test as svcs_ops. Raise an alert if SQL server is stopped:

`repeattest:svcs:svcs_ops`

`trigger:red:^MSSQLSERVER.+\sstopped\s`

Repeat the disk test as disk_ops, yellow alert if drive d: >= 70% used, red alert if drive d: >= 95% used:

`repeattest:disk:disk_ops`

`trigger:yellow:\s(7[56789]|8\d|9[01234])\% `

`trigger:red:\s(9[56789]|100)\%`

## external

`external:PRIORITY:SCHEDULE:METHOD:SCRIPT|HASH|HASHVALUE|PROCESS|ARGUMENTS`

Please note that the delimiters for this directive are slightly different - the pipe delimiter is used for some parameters to ease parsing.
external allows you to specify external scripts to run periodically to provide additional data. Scripts compatible with BBWin should work with a minimum of changes. External scripts return data back to Xymon by writing results to an external data file – see the section above in the main document.
* PRIORITY – optional – value 0-99. If specifying multiple externals, they will be executed in priority order, lower values first. If values match, async externals will be executed before sync. If priority is not specified, the lowest priority will be allocated (99).
* SCHEDULE – possible values everyscan or slowscan - when to run the external script
* METHOD – possible values sync or async – run the script synchronously (XymonPSClient waits for the script to finish before proceeding) or asynchronously (the script runs in the background)
* SCRIPT – the name of the script without path (if it exists in the externalscriptlocation and you do not wish to use update functions) or the location (UNC path or http/https/bb url) from which it can be copied / downloaded
* HASH – optional - possible values MD5, SHA1 or SHA256 - specify a hashing algorithm to check the script matches the expected HASHVALUE
* HASHVALUE – (only if HASH is specified) - specify a hash value to compare to the calculated hash value of the script
* PROCESS – optional – specify the name of a process to be used to execute the script – e.g. powershell.exe for Powershell scripts
* ARGUMENTS – optional (required if PROCESS specified) – specify any arguments to be passed to PROCESS. The text {script} can be used – it will be replaced with the full path and filename of the script. The text {scriptdir} can be used – it will be replaced with the path to the script.

If the externalscriptlocation directory does not exist and the external directive is used, XymonPSClient will attempt to create it.

If a hash algorithm and value is specified, XymonPSClient will calculate the hash of the script currently on the server and will not execute the script if the values do not match. If the script does not exist or the hash check fails, XymonPSClient will attempt to copy or download the script from the location specified by SCRIPT. 

The optional PROCESS and ARGUMENTS parameters allow a process to be called to call the script, e.g. and interpreter. If PROCESS is used, HASH, HASHVALUE and ARGUMENTS must be specified. The text {script} in the ARGUMENTS parameter will be replaced with the full path and filename of the script. For example, if the external script is a Powershell script, powershell.exe would be used for the PROCESS and –file “{script}” for the ARGUMENTS.
Care should be taken with potentially long running scripts. Do not run long running scripts synchronously as that will cause the XymonPSClient to pause until the script finishes and may well cause purple alerts. Likewise, do not run long-running scripts asynchronously on every scan, as that will cause multiple copies of the script to run.

**Examples**

`external:everyscan:sync:fsmon.vbs`

This will run fsmon.vbs (supplied with BBWin source) every scan (300 seconds by default), synchronously. The script will not be checked against a hash and therefore will not be automatically updated if it changes. XymonPSClient will attempt to execute fsmon.vbs directly. If the script does not exist, it will not be executed.

`external:everyscan:sync:http://server1/XymonPS/script.ps1|MD5|536476abc234c3c1|powershell.exe|-executionpolicy remotesigned –file "{script}"`

This will run script.ps1 every scan, synchronously. If the script does not exist or if the existing script does not match the MD5 hash 536476abc234c3c1, it will be downloaded from http://server1/XymonPS/script.ps1. If the downloaded script does not match the hash value, it will not be executed. When it is executed, a powershell.exe process will be created with the arguments specified. 

`external:slowscan:async:http://server1/XymonPS/script.ps1|MD5|536476abc234c3c1|powershell.exe|-executionpolicy remotesigned –file "{script}"`

As above, but this will run every slow scan, asynchronously. 

`external:2:everyscan:sync:bb://jmxstat.tcl|SHA1|85f0062a1fddb3add40872ce18141db9426a44fb|U:\Apps\java\jre1.8.0_144\bin\java.exe|-jar "U:\Apps\WinPSClient\ext\jmxsh-R5.jar" "U:\Apps\WinPSClient\ext\jmxstat.tcl" -J "mytomcat"`

This will run jmxstat.tcl every scan, synchronously. If the script does not exist or if the existing script does not match the SHA1 hash 85f0062a1fddb3add40872ce18141db9426a44fb, it will be downloaded from the download directory of the Xymon server.  If the downloaded script does not match the hash value, it will not be executed. When it is executed, a java.exe process will be created with the arguments specified.

## xymonlogsend

`xymonlogsend:COLOUR1:COLOUR2`

* COLOUR1 – optional – colour to send on a slow scan
* COLOUR2 – optional – colour to send on a restart, for example after a client update

Using the directive xymonlogsend in the client-local.cfg will cause the client to send the client log file to the Xymon server after every collection, as a test with green status named ‘xymonlog’. This enables you to see the log from any client from the front end dashboard.

You can optionally specify two colours, the first for a different colour on slow scan and the second for a different colour when the client is restarted (e.g. after an update). This allows you to see the history of slow scans or client updates via the front end status history options.

**Examples**

`xymonlogsend`

just sends logs with green status always

`xymonlogsend:clear:yellow`

sends logs with green status by default, with clear status when a slow scan occurs and with yellow status when the client is restarted.

## slimmode

immediately followed by zero or more of:

`services:<CSV list of services>`

`processes:<CSV list of processes>`

`sections:<CSV list of sections>`

Using the directive slimmode causes the client to reduce the amount of data it sends back to the server, and allows you some control over what is omitted.

`services:<CSV list of services>`

If slimmode is set and a list of services is provided, only those services will be reported back to the server. The names of the services should be as they are shown in the ‘Name’ column on the svcs page on Xymon.
If slimmode is set and the services directive is not, all processes will be reported as normal.

`processes:<CSV list of processes>`

If slimmode is set and a list of processes is provided, only those processes will be reported back to the server. The names of the processes should be as they are shown on the ‘cpu’ page on Xymon.
If slimmode is set and the processes directive is not, all processes will be reported as normal.

`sections:<CSV list of sections>`

The sections to include can be:
* netstat
* ports
* ipconfig
* route
* ifstat
* who
* users

If slimmode is set, all the above sections will be excluded unless they are mentioned in a sections directive.

**Example**

`slimmode`

`services:XymonPSClient,VMTools`

`processes:powershell,LogonUI`

`sections:Who`

* Only the XymonPSClient and VMTools services will be included
* Only powershell and LogonUI processes will be included
* The ‘who’ section will be populated but netstat, ports, ipconfig, route, ifstat, users will be omitted

## maxloop

`maxloop:COLLECTIONS`

* COLLECTIONS – number of loops, after which service will restart

This setting will re-start the Windows service after the set number of data collections.

If the setting is not specified or COLLECTIONS is not a number greater than zero, the service will not be restarted.
Some users have found that the XymonPSClient leaks memory (i.e. the amount of memory used keeps growing). This happens only on some builds of Windows. Some research into the issue has been done and a number of leaks have been fixed but the issue still occurs on some servers. There are many potential factors at play – OS patch level, .NET version, Powershell client version. Restarting the service periodically stops this runaway memory usage.