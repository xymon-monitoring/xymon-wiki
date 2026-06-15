# Compile Xymon

## General
Download and extract the file in a temporarily directory.

## Server

### Install the needed software

For Ubuntu:

`sudo apt-get -y install libtirpc-dev libssl-dev libcrypto++-dev libpcre3-dev libc-ares-dev `

### Configure, compile and install
Run `./configure.server` and answer the questions

Run `make` to compile the software.

Run `sudo make install` to install the Xymon server code.