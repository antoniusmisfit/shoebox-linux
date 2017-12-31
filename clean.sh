#!/usr/bin/env bash
export WORK="$(pwd)"
export ROOTFS="$WORK/rootfs"
export SRC="$WORK/sources"
export ISO="$WORK/iso"
if [[ "$1" == "-a" ]];then
rm -rf $ROOTFS $SRC $ISO
rm *.img *.iso
else
rm -rf $ROOTFS $ISO $SRC/*-*
fi
