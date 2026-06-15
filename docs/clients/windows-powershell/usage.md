# Usage

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

For more details, see the [external](remote-settings.md#external) directive.

If you need finer control of when your script is run, there are two options:

* Use Windows Task Scheduler to execute the script, but have your script write external data results to the externaldatalocation or localdatalocation. XymonPSClient will pick it up.
* Write your script so that it writes a small data file containing the date/time it last sent results (you could use the file modified timestamp for this). Then only send new results if your desired interval has expired.

In either case, you may want to use the “lifetime” option to prevent your tests going purple (see External Data below).

Some scripts (e.g. those supplied with BBWin) use registry keys to determine the location of the script and data directories. The easiest way to adjust for XymonPSClient is to create or update the keys, pointing the values to the new locations. Note that on 64 bit platforms, the keys may have been created by BBWin under the Wow6432Node (e.g. HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\BBWin), you will need to recreate the keys in the standard location HKEY_LOCAL_MACHINE\SOFTWARE\BBWin.

## Returning data to Xymon

There are a number of options for returning data from external scripts to Xymon:

* Write a file to externaldatalocation – results in a ‘status’ message back to Xymon - this is the recommended approach, see [External data](#external-data) below
* Write a file to localdatalocation – results in the file content being contained in the core ‘client’ message back to Xymon
* Send a message back to Xymon directly using `xymon.ps1` - this is an old approach that is no longer supported, see [Using xymon.ps1](#using-xymonps1) below

## External data

For external data, XymonPSClient supports the same file format as BBWin. XymonPSClient will always look for external data in the location specified by the XML configuration ‘externaldatalocation’ – by default, the ‘tmp’ subdirectory in the installation directory. This data collection occurs if the directory exists, regardless of whether any external scripts are defined. This allows you to use completely external scripts / processes e.g. via Windows Task Scheduler and still have the results reported back to Xymon.

The BBWin format is a text file, named for the test – i.e. the name of the file controls the name of the test that will be shown on the dashboard.
Any files with ‘.’ in the filename are ignored – this is in line with BBWin functionality. Therefore, filenames with extensions (e.g. testname.txt) will be ignored.

The filename can be used to send test data as if it has come from a different host. In this case, the filename should be TESTNAME^HOSTNAME. This is useful if you are running external scripts on a server but want the results to appear in Xymon separately (for example, for monitoring a SAN).

The data file will not be read if it is locked for writing by any other process. This is to prevent data being sent which is only partially written - the file will be picked up on a later scan once it is no longer locked.

The contents of the file determine what kind of message is sent to Xymon, and must be in one of the following three formats. Once a file has been read (regardless of which format matched, or even if none did), it is deleted.

### status format

`<GROUPCOLOUR>[+LIFETIME] <MESSAGE>`

* GROUPCOLOUR – red, yellow, green or clear – the colour for the group (blue and purple are not allowed as they are used internally by Xymon server)
* +LIFETIME – optional – how long before Xymon should turn the status purple if no further results are received, specified in minutes (but supports 'h', 'd' or 'w' suffix e.g. 5h for 5 hours)
* MESSAGE  - the message to be displayed. This message can span multiple lines and can include “&colour” e.g. &green / &yellow / &red to display a subtest with the corresponding coloured GIF.

This results in a `status` message being sent to Xymon for the test, with the test name and host name taken from the file name as described above.

For example, the external script fsmon supplied with the BBWin source writes external files with the following contents:

```
green 14/01/2016 14:37:07 [SERVER1]

&green checking directory extdirtest 'c:\temp' - Rules are <50 and <100 - Actually 5 file(s)
```

Here the group colour is green and the subtest colour is also green, no lifetime has been specified so the result will turn purple after the default interval if no more test results are sent.

### trends format

`trends<DATA>`

A file whose contents start with `trends` (immediately followed by the rest of the data, no separating space is added) is sent to Xymon as a `data` message for the `trends` section of the test's host, i.e. `data <HOSTNAME>.trends<DATA>`. This is used to feed graphs (RRDs) rather than to set a status.

### usermsg format

`usermsg <DATA>`

A file whose contents start with `usermsg ` is sent to Xymon verbatim, unchanged. The file content must therefore already be a complete, valid Xymon `usermsg` command - the filename (and therefore TESTNAME/HOSTNAME) has no effect for this format.

### Unrecognised content

If the file content does not match any of the above formats, nothing is sent to Xymon. The file is still deleted, and a warning together with the file's content is written to the client log file.

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

`xymon.ps1` is an old script that is no longer supported and may be removed from the distribution in a future version. It is kept here for reference only, for users who still have scripts depending on it.

The recommended way for an external script to send data to Xymon is to write a file to the `externaldatalocation` (`tmp` by default) in one of the formats described under [External data](#external-data) above - XymonPSClient will then pick it up and send it on the next scan, without needing a separate communications program.

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
