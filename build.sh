#!/bin/sh
set -ex
# Setup env
export WORK="$(pwd)"
export ROOTFS="$WORK/rootfs"
export SRC="$WORK/sources"
export ISO="$WORK/iso"
# Make the folders
mkdir -p $SRC $ROOTFS $ISO
export CFLAGS="-Os -s"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-static"
export JOBS=$(expr $(nproc) + 1)
export KERNEL_VERSION=4.14.5
export BUSYBOX_VERSION=1.27.2
export SYSLINUX_VERSION=6.03
export LINKS_VERSION=2.14
#export TERMINUS_VERSION=4.46
export DISTRO_NAME="Shoebox Linux"
#Download required sources
cd $SRC
wget -O kernel.tar.xz -c https://kernel.org/pub/linux/kernel/v4.x/linux-$KERNEL_VERSION.tar.xz
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
mkdir -p dev/pts proc src sys etc/service etc/skel home var/spool/cron/crontabs tmp
#Copy source scripts into /src folder
cp $WORK/*.sh src
cp $WORK/LICENSE src
cp $WORK/README.md src
echo "127.0.0.1      localhost" > etc/hosts
echo "localnet    127.0.0.1" > etc/networks
echo "localhost" > etc/hostname
echo "order hosts,bind" > etc/host.conf
echo "multi on" >> etc/host.conf
touch etc/issue
echo "root::0:0:root:/root:/bin/sh" > etc/passwd
echo "root:x:0:" > etc/group
cat > etc/skel/.profile << EOF
PS1="[\u@\h \w]\\$ "
alias ll="ls -l"
alias la="ll -a"
EOF
touch etc/fstab
cat > etc/banner.txt << EOF
Welcome to$(setterm -foreground blue)
     _           _              _ _             
 ___| |_ ___ ___| |_ ___ _ _   | |_|___ _ _ _ _ 
|_ -|   | . | -_| . | . |_'_|  | | |   | | |_'_|
|___|_|_|___|___|___|___|_,_|  |_|_|_|_|___|_,_|
$(setterm --default)
EOF
printf "Shoebox" > etc/hostname
#Set up Rocketbox init system and networking
cat > etc/rocketbox-init << EOF
#!/bin/sh
echo "Rocketbox init v0.2alpha"
echo "Starting up..."
dmesg -n 1
echo "Mounting filesystems..."
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
mount -t devpts none /dev/pts
mount -t tmpfs none /tmp -o mode=1777
echo "Starting mdev hotplug..."
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s
echo "Synchronizing clock..."
hwclock -u -s
echo "Mounting all from /etc/fstab..."
mount -a
echo "Read and write premissions..."
mount -o remount,rw /
echo "Setting hostname..."
hostname -F /etc/hostname
echo "Setting up networking..."
for DEVICE in /sys/class/net/* ; do
  echo "Found network device \${DEVICE##*/}"
  ip link set \${DEVICE##*/} up
  [ \${DEVICE##*/} != lo ] && udhcpc -b -i \${DEVICE##*/} -s /etc/rc.dhcp
done
echo "Starting services and userspace..."
exec /sbin/init
EOF
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
cat > etc/rocketbox-shutdown << EOF
echo "Shutting down..."
hwclock -u -w
sync
umount -a -r
echo "Come back soon! :)"
sleep 1
EOF
cat > etc/rocketbox-service << DEOF
#!/bin/sh

do_help()
{
cat << EOF
Usage:
\$0 [start|stop|status|restart|add|remove] /path/to/service

Options:
start	Start a service.
stop	Stop a running service.
restart	Stop, then start a previously running service.
status	Report the status of the given service.
add	Adds a service directory to /etc/service via soft linking.
remove	Removes a service from /etc/service by removing the soft link.
EOF
}
case \$1 in
	start|restart) sv up /etc/service/\$(basename \$2);;
	stop) sv down /etc/service/\$(basename \$2);;
	status) sv \$1 /etc/service/\$(basename \$2);;
	add) ln -s \$2 /etc/service/\$(basename \$2);;
	remove) rm -rf /etc/service/\$(basename \$2);;
	*) do_help;exit;;
esac
DEOF
chmod +x etc/rocketbox-*
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
make mrproper defconfig bzImage -j$JOBS
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
