#!/bin/sh
# Use this script without arguments to run the generated ISO image with QEMU.
# If you pass '-hdd' or '-h' the virtual hard disk 'hdd.img' will be attached.
# Note that this virtual hard disk has to be created in advance. You can use
# the command "truncate -s 1GB hdd.img" to generate the hard disk image file.
#
# If this script is run without a running graphical server, it will run QEMU
# using a curses interface.

if [ "$TERM" = "linux" ];then
cmd="qemu-system-$(uname -m) -curses -m 1G -cdrom shoebox_linux_live.iso -boot d"

if [ "$1" = "-hdd" -o "$1" = "-h" ] ; then
  echo "Starting QEMU curses with attached ISO image and hard disk."
  $cmd -hda hdd.img
else
  echo "Starting QEMU curses with attached ISO image."
  $cmd
fi
else
cmd="qemu-system-$(uname -m) -m 1G -cdrom shoebox_linux_live.iso -boot d -vga std"

if [ "$1" = "-hdd" -o "$1" = "-h" ] ; then
  echo "Starting QEMU with attached ISO image and hard disk."
  $cmd -hda hdd.img > /dev/null 2>&1 &
else
  echo "Starting QEMU with attached ISO image."
  $cmd > /dev/null 2>&1 &
fi
fi
