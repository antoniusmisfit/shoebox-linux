#!/bin/sh
# Use this script without arguments to run the generated ISO image with QEMU.
# If you pass '-hdd' or '-h' the virtual hard disk 'hdd.img' will be attached.
# Note that this virtual hard disk has to be created in advance. You can use
# the command "truncate -s 1GB hdd.img" to generate the hard disk image file.
#
# This script is to be used only for Linux hosts not running an X server.

cmd="qemu-system-$(uname -m) -curses -m 1G -cdrom shoebox_linux_live.iso -boot d"

if [ "$1" = "-hdd" -o "$1" = "-h" ] ; then
  echo "Starting QEMU with attached ISO image and hard disk."
  $cmd -hda hdd.img
else
  echo "Starting QEMU with attached ISO image."
  $cmd
fi
