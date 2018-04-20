# shoebox-linux
Shoebox Linux is a tiny Busybox-based Linux environment inspired by [Minimal Linux Script](https://github.com/ivandavidov/minimal-linux-script) and [Minimal Linux Live](https://github.com/ivandavidov/minimal) by Ivan Davidov. It currently features the links web browser, the [Rocketbox](https://github.com/antoniusmisfit/rocketbox-init) init system, and the [Shoeblog](https://github.com/antoniusmisfit/shoeblog) tiny blog engine.
# Building Shoebox Linux
## Dependencies
On Debian-based systems, installing the build-essential and xorriso packages should satisfy all build dependencies for Shoebox Linux. On other Linux systems, please check your package manager and/or distro documentation for details and let me know if you are successful.

## Compiling Shoebox
Simply copy the build.sh script into an empty directory, navigate to the directory, and then run as root:
```
sudo ./build.sh
```
If all goes well, you should have a "shoebox_linux_live.iso" file created in the current directory, ready to be burned to CD/USB or testing as a virtual machine.
## Testing the build
To test out your build of Shoebox Linux, run the qemu.sh script. When the login prompt appears, enter "root" and press Enter. You will then be logged into the root account and a shell prompt will appear, ready for your commands.
## Cleaning up
If you want to clean the work area before recompiling Shoebox Linux, simply run the clean.sh script in a terminal as root:
```
#Use without the "-a" argument to keep pre-downloaded tarballs, ISO and qemu hard drive images.
sudo ./clean.sh -a
```
# TODO
* Add a package manager.
* Get basic networking working right.(requires GLIBC or musl)
* Add a C compiler to the system. (Either tcc or gcc)
