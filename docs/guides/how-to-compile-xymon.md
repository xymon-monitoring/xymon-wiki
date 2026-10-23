# Compile Xymon

## General
Download and extract the file in a temporarily directory.

## Server

### Install the needed software

The libraries a server build needs, and one install command per system
(Debian/Ubuntu, RHEL family, Fedora, openSUSE, Alpine, Arch, the BSDs,
macOS), are in the "Installing on common systems" appendix of
`docs/install.html` in the Xymon source
([`docs/install.html.DIST`](https://github.com/xymon-monitoring/xymon/blob/main/docs/install.html.DIST)
on GitHub).

### Configure, compile and install
Run `./configure.server` and answer the questions

Run `make` to compile the software.

Run `sudo make install` to install the Xymon server code.