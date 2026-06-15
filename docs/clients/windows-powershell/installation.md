# Installation and usage

## Files

The following files are required:

* Nssm.exe
* XymonClient.ps1
* Xymonclient_config.xml

Any other files are legacy from older versions and can be deleted. In particular, XymonPSClient.exe is not required.

## Before installing

The script is designed to be installed as a Windows service. In the original script, a renamed srvany.exe was used (XymonPSClient.exe).

In more recent versions, the decision has been made to switch to use NSSM (http://nssm.cc/). This is a public domain service manager very similar to srvany. It offers the feature of restarting the script if it is stopped for any reason – for example, if a user kills the PowerShell process. It also allows the use of 64-bit processes on 64-bit operating systems.

Note that the version of NSSM supplied in this repository is for x64 systems. If you are running an x86 (32-bit) system, please download the 32-bit bit nssm.exe from http://nssm.cc/.

You may need to “unblock” execution of the downloaded scripts and files depending on your Windows settings. To do this, right-click each file and select Properties. If you see the option to unblock, please click the Unblock button.

## Installation steps

Installation of the client is straightforward:

1. Review xymonclient_config.xml and at the least, set the Xymon server address.
1. Copy the following files to a directory on the target server (e.g. c:\program files\xymon)
   * `Xymonclient.ps1`
   * `Nssm.exe`
   * `Xymonclient_config.xml`
1. Run the following command to install the service from a PowerShell prompt (may need to be an administrative prompt):
   * `.\xymonclient.ps1 install`
1. Either review and start the service in Windows services control panel or run:
   * `.\xymonclient.ps1 start`

The script will create the windows service entry using the SYSTEM or LOCALSYSTEM account to run the service.

If BBWin or the original PowerShell client is running, it’s best to stop and disable those services first.

## Powershell execution policy

In step 3 above, if the PowerShell execution policy has not been set then you will receive a PowerShell error. You can either run “Set-ExecutionPolicy RemoteSigned” from an administrative PowerShell prompt or start powershell using “powershell.exe -executionpolicy remotesigned” from Start->Run.

## Uninstallation

1. Sop the XymonPSClient service - run the following commands to uninstall the service from a PowerShell prompt (may need to be an administrative prompt):
   * `cd "c:\program files\xymon"` (substitute the installation location)
   * `.\xymonclient.ps1 stop`
   * `.\xymonclient.ps1 uninstall`
2. You can then delete all files from the installation directory. There may also be two log files (by default in the c:\ directory), xymonclient.log and xymon-lastcollect.txt which can also be deleted.

## External scripts

As of version 2.1, XymonPSClient supports external scripts. Along with external data, this has been designed to try and support existing external scripts that may be being used with BBWin with a minimum of modification.

XymonPSClient will look for and install scripts in the ‘externalscriptlocation’ XML configuration parameter, which defaults to the ‘ext’ subdirectory of the installation directory.

The main differences between BBWin and XymonPSClient concern how scripts are defined, scheduling and automatic deployment and update.

Defining scripts is done via the new ‘external’ directive for client-local.cfg. This allows you to define, deploy and update from the server rather than having to deploy to each client manually.

Unlike BBWin, XymonPSClient does not allow you to schedule a script to be run periodically, rather it offers three scheduling options:

* Run every scan (every 300 seconds by default – set by XML configuration item ‘loopinterval’)
* Run every ‘slow’ scan (every 6 hours by default – set by XML configuration items ‘loopinterval’ and ‘slowscanrate’)
* Run every N'th scans,  set by using `scan,N` as the SCHEDULE value in the ‘external’ directive, where N is the number of scans between runs (e.g. `scan,12` with the default ‘loopinterval’ of 300 seconds runs the script approximately every hour)

Additionally, XymonPSClient offers two execution methods:

* Synchronous – XymonPSClient launches the script process and then waits for completion – recommended for scripts with a short execution time (e.g. less than ‘loopinterval’) and which require frequent updates
* Asynchronous – XymonPSClient launches the script process and does not wait for completion – the script runs in the background – recommended for scripts with a long execution time or infrequent updates

When using asynchronous scripts, you can use file locking to prevent XymonPSClient from picking up results before they’re ready. XymonPSClient will not pick up any file that is locked for writing.

Care should be taken with potentially long running scripts. Do not run long running scripts synchronously as that will cause the XymonPSClient to pause until the script finishes and may well cause purple alerts. Likewise, do not run long-running scripts asynchronously on every scan, as that will cause multiple copies of the script to run.

For more details, see the ‘external’ directive below.

If you need finer control of when your script is run, there are two options:

* Use Windows Task Scheduler to execute the script, but have your script write external data results to the externaldatalocation or localdatalocation. XymonPSClient will pick it up.
* Write your script so that it writes a small data file containing the date/time it last sent results (you could use the file modified timestamp for this). Then only send new results if your desired interval has expired.

In either case, you may want to use the “lifetime” option to prevent your tests going purple (see External Data below).

Some scripts (e.g. those supplied with BBWin) use registry keys to determine the location of the script and data directories. The easiest way to adjust for XymonPSClient is to create or update the keys, pointing the values to the new locations. Note that on 64 bit platforms, the keys may have been created by BBWin under the Wow6432Node (e.g. HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\BBWin), you will need to recreate the keys in the standard location HKEY_LOCAL_MACHINE\SOFTWARE\BBWin.

## Returning data to Xymon

There are a number of options for returning data from external scripts to Xymon:

* Write a file to externaldatalocation – results in a ‘status’ message back to Xymon
* Write a file to localdatalocation – results in the file content being contained in the core ‘client’ message back to Xymon
* Send a message back to Xymon directly (e.g. using ‘xymon.ps1’ available from the XymonPSClient svn repository as a basis)

## External data

For external data, XymonPSClient supports the same file format as BBWin. XymonPSClient will always look for external data in the location specified by the XML configuration ‘externaldatalocation’ – by default, the ‘tmp’ subdirectory in the installation directory. This data collection occurs if the directory exists, regardless of whether any external scripts are defined. This allows you to use completely external scripts / processes e.g. via Windows Task Scheduler and still have the results reported back to Xymon.

The BBWin format is a text file, named for the test – i.e. the name of the file controls the name of the test that will be shown on the dashboard.
Any files with ‘.’ in the filename are ignored – this is in line with BBWin functionality. Therefore, filenames with extensions (e.g. testname.txt) will be ignored.

The filename can be used to send test data as if it has come from a different host. In this case, the filename should be TESTNAME^HOSTNAME. This is useful if you are running external scripts on a server but want the results to appear in Xymon separately (for example, for monitoring a SAN).

The contents of the file should be as follows:

`<GROUPCOLOUR>[+LIFETIME] <MESSAGE>`

* GROUPCOLOUR – red, yellow, green or clear – the colour for the group (blue and purple are not allowed as they are used internally by Xymon server)
* +LIFETIME – optional – how long before Xymon should turn the status purple if no further results are received, specified in minutes (but supports 'h', 'd' or 'w' suffix e.g. 5h for 5 hours)
* MESSAGE  - the message to be displayed. This message can span multiple lines and can include “&colour” e.g. &green / &yellow / &red to display a subtest with the corresponding coloured GIF.

For example, the external script fsmon supplied with the BBWin source writes external files with the following contents:

```
green 14/01/2016 14:37:07 [SERVER1]

&green checking directory extdirtest 'c:\temp' - Rules are <50 and <100 - Actually 5 file(s)
```

Here the group colour is green and the subtest colour is also green, no lifetime has been specified so the result will turn purple after the default interval if no more test results are sent.

## Local data

Data written to the localdatalocation will be read and included in the core ‘client’ message back to Xymon. It will be included in a section named [local:`<filename>`], where `<filename>` is the name of the file the data was found in. The data will not be parsed, it will simply be copied into the message.

The data file will not be read if it is locked for writing by any other process. This is to prevent data being sent which is only partially written.

Any data files read successfully will be removed (deleted) once included in the message.

This local data feature is designed to replicate the behaviour of the Linux client. The data can be retrieved later using a ‘clientlog’ xymon command:

`xymon 0 "clientlog <client host> section=local:<filename>"`

Example: a script writes a file named ‘sqlversion’ to the localdatalocation, containing the following text:

`Microsoft SQL Server 2014 (SP2-GDR) (KB3194714) - 12.0.5203.0 (X64)`

XymonPSClient will include the following in the ‘client’ message:

```
[local:sqlversion]
Microsoft SQL Server 2014 (SP2-GDR) (KB3194714) - 12.0.5203.0 (X64)
```

The file ‘sqlversion’ will be deleted.

## Using xymon.ps1

The powershell version of the 'xymon' communications program will accept similar commands to the native UNIX version. This command can be used to send various messages to the Xymon server. see the following syntax:

```
C:\WinPSClient>powershell -file xymon.ps1 -help
Usage : xymon.ps1 [-recipient RECIPIENT] -message 'DATA'|-msgfile FILE
            xymon.ps1 [-recipient RECIPIENT] -message 'download FILE' [-output RECEIVED]

   RECIPIENT: IP-address or hostname (overrides configured value)
   DATA: Message to send, or '@' to read from stdin
```

One of either -message or -msgfile must be provided and if using the latter, then FILE will be deleted after successful transmission of DATA!
For the special case of the message 'download FILE' then the received data will be saved locally in 'FILE' but this can be overridden using the -output option.
