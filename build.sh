#!/bin/sh
set -ex
KERNEL_VERSION=4.12.3
BUSYBOX_VERSION=1.27.1
SYSLINUX_VERSION=6.03
DISTRO_NAME="Shoebox Linux"
wget -O kernel.tar.xz http://kernel.org/pub/linux/kernel/v4.x/linux-$KERNEL_VERSION.tar.xz
wget -O busybox.tar.bz2 http://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
wget -O syslinux.tar.xz http://kernel.org/pub/linux/utils/boot/syslinux/syslinux-$SYSLINUX_VERSION.tar.xz
tar -xvf kernel.tar.xz
tar -xvf busybox.tar.bz2
tar -xvf syslinux.tar.xz
mkdir isoimage
cd busybox-$BUSYBOX_VERSION
make distclean defconfig
sed -i "s/.*CONFIG_STATIC.*/CONFIG_STATIC=y/" .config
make busybox install
cd _install
rm -f linuxrc
mkdir -p dev proc sys etc/service home
touch etc/group etc/passwd
cat > init << EOF
#!/bin/sh
dmesg -n 1
echo "Mounting filesystems..."
mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys
echo "Starting sbin/init..."
exec /sbin/init
EOF
chmod +x init
cat > etc/inittab << EOF
::restart:/sbin/init
::shutdown:echo "Shutting down..."
::shutdown:sync
::shutdown:umount -a -r
::shutdown:echo "Come back soon! :)"
::shutdown:sleep 1
::ctrlaltdel:/sbin/reboot
::once:echo "Welcome to $DISTRO_NAME!"
::once:runsvdir /etc/service
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
