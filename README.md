# shoebox-linux
Shoebox Linux is a tiny Busybox-based Linux environment inspired by Minimal Linux Script and Minimal Linux Live by Ivan Davidov.
# Building Shoebox Linux
## Dependencies
On Debian-based systems, installing the build-essential and xorriso packages should satisfy all build dependencies for Shoebox Linux.

## Compiling Shoebox
Simply copy the build.sh script into an empty directory, navigate to the directory, and then run as root:
```
sudo ./build.sh
```
If all goes well, you should have a "shoebox_linux_live.iso" file created in the current directory, ready to be burned to CD/USB or testing as a virtual machine.
## Testing the build
To test out your build of Shoebox Linux, run the qemu.sh script.
## Cleaning up
If you want to clean the work area before recompiling Shoebox Linux, simply run the clean.sh script in a terminal as root:
```
sudo ./clean.sh
```
# TODO
* Replace the basic init with something more robust.
* Create a welcome banner.
* Add a package manager.
