#!/usr/bin/env bash

if [[ "$1" == "-a" ]];then
rm -rf busybox* isoimage kernel* linux* *.iso syslinux*
else
rm -rf busybox-* isoimage kernel/ linux-* syslinux-*
fi
