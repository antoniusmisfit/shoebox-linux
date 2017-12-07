# shoebox-linux
Shoebox Linux is a tiny Busybox-based Linux environment inspired by Minimal Linux Script and Minimal Linux Live by Ivan Davidov.
# Building Shoebox Linux
## Dependencies
On Debian-based systems, installing the build-essential and xorriso packages should satisfy all build dependencies for Shoebox Linux.

## Compiling Shoebox

Simply run the build.sh script in a terminal as root:
```
sudo ./build.sh
```
If all goes well, you should have a "minimal_linux_live.iso" file created in the current directory, ready to be burned to CD/USB or testing as a virtual machine.
## Cleaning up
If you want to clean the work area before recompiling Shoebox Linux, simply run the clean.sh script in a terminal as root:
```
sudo ./clean.sh
```