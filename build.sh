#!/bin/sh
set -ex
# Useful function from MLL
yconfig() {
	while [ $# -ne 0 ]; do
		sed -i "s/.*CONFIG_$1\ .*/CONFIG_$1=y/" .config
		grep ^"CONFIG_$1=y" .config || echo "CONFIG_$1=y" >> .config
		shift 1
	done
}
# Setup env
export WORK=`realpath --no-symlinks $PWD`
export ROOTFS="$WORK/rootfs"
export SRC="$WORK/sources"
export ISO="$WORK/iso"
# Make the folders
mkdir -p $SRC $ROOTFS $ISO
# Compilation flags
export CFLAGS="-Os -s"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-static"
export JOBS=$(expr $(nproc) + 1)
# Version numbers for critical software
export KERNEL_VERSION=5.1.16
export BUSYBOX_VERSION=1.31.0
export SYSLINUX_VERSION=6.03
export LINKS_VERSION=2.19
# Name of distribution
export DISTRO_UNAME="Shoebox"
export DISTRO_NAME="$DISTRO_UNAME Linux"
#Download required sources
cd $SRC
wget -O kernel.tar.xz -c https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$KERNEL_VERSION.tar.xz
wget -O busybox.tar.bz2 -c https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
wget -O syslinux.tar.xz -c https://kernel.org/pub/linux/utils/boot/syslinux/syslinux-$SYSLINUX_VERSION.tar.xz
wget -O links.tar.bz2 -c http://links.twibright.com/download/links-$LINKS_VERSION.tar.bz2
#wget -O terminus.tar.gz -c https://downloads.sourceforge.net/project/terminus-font/terminus-font-4.46/terminus-font-4.46.tar.gz
for eachpkg in *.tar.*;do
tar -xvf $eachpkg
done
#Install Busybox
cd $SRC
cd busybox-$BUSYBOX_VERSION
make distclean defconfig
sed -i "s/.*CONFIG_STATIC.*/CONFIG_STATIC=y/" .config
make busybox -j$JOBS
make CONFIG_PREFIX=$ROOTFS install
cd $ROOTFS
rm -f linuxrc
#Set up root filesystem
mkdir -p dev/pts proc src sys root mnt etc/service etc/skel home var/spool/cron/crontabs tmp
#Copy source scripts into /src folder
cp $WORK/*.sh src
cp $WORK/LICENSE src
cp $WORK/*.md src
echo "127.0.0.1      localhost" > etc/hosts
echo "localnet    127.0.0.1" > etc/networks
printf "$DISTRO_UNAME" > etc/hostname
cat > etc/host.conf << EOF
order hosts,bind
multi on
EOF
touch etc/issue
echo "root::0:0:root:/root:/bin/sh" > etc/passwd
echo "root:x:0:" > etc/group
cat > etc/profile << EOF
export PS1="\[\e[32m\][\[\e[m\]\[\e[37m\]\u\[\e[m\]\[\e[32m\]@\[\e[m\]\[\e[37m\]\h\[\e[m\] \[\e[35m\]\w\[\e[m\]\[\e[32m\]]\[\e[m\]\\$ "
alias ll="ls -l"
alias la="ll -a"
EOF
touch etc/fstab
cat > etc/banner.txt << EOF
$(clear)
Welcome to$(setterm -foreground blue)
     _           _              _ _             
 ___| |_ ___ ___| |_ ___ _ _   | |_|___ _ _ _ _ 
|_ -|   | . | -_| . | . |_'_|  | | |   | | |_'_|
|___|_|_|___|___|___|___|_,_|  |_|_|_|_|___|_,_|
$(setterm --default)
EOF
#Set up Rocketbox init system and networking
wget -O etc/rocketbox-init https://raw.githubusercontent.com/antoniusmisfit/rocketbox-init/master/rocketbox-init
cat > etc/rc.dhcp << EOF
ip addr add \$ip/\$mask dev $interface
if [ "\$router" ]; then
  ip route add default via \$router dev \$interface
fi

if [ "\$ip" ]; then
  echo "DHCP configuration for device \$interface"
  echo "ip:     \$ip"
  echo "mask:   \$mask"
  echo "router: \$router"
fi
EOF
cat > etc/resolv.conf << EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
ln -s etc/rocketbox-init init
for eachcomp in shutdown service;do
wget -O etc/rocketbox-$eachcomp https://raw.githubusercontent.com/antoniusmisfit/rocketbox-init/master/rocketbox-$eachcomp
done
chmod +x etc/rocketbox-*
wget -O usr/bin/shoeblog https://raw.githubusercontent.com/antoniusmisfit/shoeblog/master/shoeblog
chmod +x usr/bin/shoeblog
cat > etc/inittab << EOF
::restart:/sbin/init
::shutdown:/etc/rocketbox-shutdown
::ctrlaltdel:/sbin/reboot
::once:runsvdir /etc/service
::once:crond
::once:cat /etc/banner.txt
tty1::respawn:/sbin/getty 0 tty1
EOF
cd $SRC
cd links-$LINKS_VERSION
./configure \
	--prefix=/usr \
	--disable-shared \
	--disable-graphics \
	--disable-utf8 \
	--without-ipv6 \
	--without-ssl \
	--without-zlib \
	--without-x
make -j$JOBS
make DESTDIR=$ROOTFS install
cd $ROOTFS
find . | cpio -R root:root -H newc -o | gzip > $ISO/rootfs.gz
cd $SRC
cd linux-$KERNEL_VERSION
unset LDFLAGS
make mrproper defconfig -j$JOBS
yconfig CC_OPTIMIZE_FOR_SIZE OPTIMIZE_INLINING BLK_DEV_SD \
	EXT2_FS EXT3_FS EXT4_FS MSDOS_FS VFAT_FS PROC_FS TMPFS DEVTMPFS DEVTMPFS_MOUNT \
	PPP PPP_ASYNC PPP_SYNC_TTY SMP \
	HID_GENERIC USB_HID USB_SUPPORT USB_XHCI_HCD USB_EHCI_HCD USB_OHCI_HCD \
	PARTITION_ADVANCED EFI_PARTITION \
	EFI EFI_STUB EFI_MIXED EFI_VARS \
	NET PACKET UNIX INET IPV6 NETDEVICES ETHERNET
yes '' | make silentoldconfig -j$JOBS
make bzImage -j$JOBS
cp arch/x86/boot/bzImage $ISO/kernel.gz
cd $ISO
cp $SRC/syslinux-$SYSLINUX_VERSION/bios/core/isolinux.bin .
cp $SRC/syslinux-$SYSLINUX_VERSION/bios/com32/elflink/ldlinux/ldlinux.c32 .
echo 'default kernel.gz initrd=rootfs.gz' > ./isolinux.cfg
xorriso \
  -as mkisofs \
  -o $WORK/shoebox_linux_live.iso \
  -b isolinux.bin \
  -c boot.cat \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  $ISO
cd ..
set +ex
