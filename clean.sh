#!/usr/bin/env bash

if [[ "$1" == "-a" ]];then
rm -rf busybox* isoimage kernel* linux* *.iso syslinux* dhcpcd* links*
rm hdd.img
else
rm -rf busybox-* isoimage kernel/ linux-* syslinux-* links-* dhcpcd-*
fi
