#!/bin/sh
set -ex
KERNEL_VERSION=4.14.5
BUSYBOX_VERSION=1.27.2
SYSLINUX_VERSION=6.03
DISTRO_NAME="Shoebox Linux"
if [ ! -e kernel.tar.xz ];then
wget -O kernel.tar.xz http://kernel.org/pub/linux/kernel/v4.x/linux-$KERNEL_VERSION.tar.xz
fi
if [ ! -e busybox.tar.bz2 ];then
wget -O busybox.tar.bz2 http://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
fi
if [ ! -e syslinux.tar.xz ];then
wget -O syslinux.tar.xz http://kernel.org/pub/linux/utils/boot/syslinux/syslinux-$SYSLINUX_VERSION.tar.xz
fi
for eachpkg in kernel.tar.xz busybox.tar.bz2 syslinux.tar.xz;do
tar -xvf $eachpkg
done
mkdir isoimage
cd busybox-$BUSYBOX_VERSION
make distclean defconfig
sed -i "s/.*CONFIG_STATIC.*/CONFIG_STATIC=y/" .config
make busybox install
cd _install
rm -f linuxrc
mkdir -p dev proc sys etc/service home var/spool/cron/crontabs
touch etc/group etc/passwd
printf "Shoebox" > etc/hostname
cat > etc/rocketbox-init << EOF
#!/bin/sh
echo "Rocketbox init v0.1alpha"
echo "Starting up..."
dmesg -n 1
echo "Mounting filesystems..."
mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys
echo "Setting hostname..."
hostname -F /etc/hostname
echo "Starting services and userspace..."
exec /sbin/init
EOF
ln -s etc/rocketbox-init init
cat > etc/rocketbox-shutdown << EOF
echo "Shutting down..."
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
Usage: \$0 [start|stop|status|restart|add|remove] /path/to/service

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
	start|stop|restart|status) sv \$1 \$2;;
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
::once:echo "Welcome to $DISTRO_NAME!"
::once:runsvdir /etc/service
::once:crond
::respawn:/bin/cttyhack /bin/sh
EOF
find . | cpio -R root:root -H newc -o | gzip > ../../isoimage/rootfs.gz
cd ../../linux-$KERNEL_VERSION
make mrproper defconfig bzImage
cp arch/x86/boot/bzImage ../isoimage/kernel.gz
cd ../isoimage
cp ../syslinux-$SYSLINUX_VERSION/bios/core/isolinux.bin .
cp ../syslinux-$SYSLINUX_VERSION/bios/com32/elflink/ldlinux/ldlinux.c32 .
echo 'default kernel.gz initrd=rootfs.gz' > ./isolinux.cfg
xorriso \
  -as mkisofs \
  -R \
  -r \
  -o ../shoebox_linux_live.iso \
  -b isolinux.bin \
  -c boot.cat \
  -input-charset UTF-8 \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  ./
cd ..
set +ex
