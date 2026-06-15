# Installation

## Files

The following files are required:

* nssm.exe
* xymonclient.ps1
* xymonclient_config.xml

Any other files are legacy from older versions and can be deleted. In particular, XymonPSClient.exe is not required.

## Before installing

The script is designed to be installed as a Windows service. In the original script, a renamed `srvany.exe` was used (`XymonPSClient.exe`).

In more recent versions, the decision has been made to switch to use NSSM ([NSSM](http://nssm.cc/)). This is a public domain service manager very similar to srvany. It offers the feature of restarting the script if it is stopped for any reason – for example, if a user kills the PowerShell process. It also allows the use of 64-bit processes on 64-bit operating systems.

Note that the version of NSSM supplied in this repository is for x64 systems. If you are running an x86 (32-bit) system, please download the 32-bit bit nssm.exe from [NSSM](http://nssm.cc/).

You may need to “unblock” execution of the downloaded scripts and files depending on your Windows settings. To do this, right-click each file and select Properties. If you see the option to unblock, please click the Unblock button.

## Installation steps

Installation of the client is straightforward:

1. Review xymonclient_config.xml and at the least, set the Xymon server address.
1. Copy the following files to a directory on the target server (e.g. c:\program files\xymon)
   * `xymonclient.ps1`
   * `nssm.exe`
   * `xymonclient_config.xml`
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

## Next steps

See [Usage](usage.md) for how to configure external scripts, return data to Xymon, and use `xymon.ps1`.
