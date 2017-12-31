#!/bin/sh
export WORK="$(pwd)"
export ROOTFS="$WORK/rootfs"
export SRC="$WORK/sources"
export ISO="$WORK/iso"
# Make the folders and remove old
rm -rf $ROOTFS $SRC $ISO
if [[ "$1" == "-a" ]];then
rm -rf $ROOTFS $SRC $WORK
rm hdd.img
else
rm -rf $ROOTFS $WORK $SRC/*-*
fi
