#!/bin/bash
# confirm you can access the internet
if [[ ! $(curl -Is http://www.google.com/ | head -n 1) =~ "200 OK" ]]; then
  echo "Your Internet seems broken. Press Ctrl-C to abort or enter to continue."
  read
fi

# make 2 partitions on the disk.
parted -s /dev/sda mktable msdos
parted -s /dev/sda mkpart primary 0% 100m
parted -s /dev/sda mkpart primary 100m 100%

# make filesystems
# /boot
mkfs.ext4 /dev/sda1
# /
mkfs.btrfs /dev/sda2

# set up /mnt
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# rankmirrors to make this faster (though it takes a while)
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig
rankmirrors -n 6 /etc/pacman.d/mirrorlist.orig >/etc/pacman.d/mirrorlist
pacman -Syy

# install base packages (take a coffee break if you have slow internet)
pacstrap /mnt base base-devel

# install syslinux
arch-chroot /mnt pacman -S syslinux --noconfirm

# copy ranked mirrorlist over
cp /etc/pacman.d/mirrorlist* /mnt/etc/pacman.d

# generate fstab
genfstab -p /mnt >>/mnt/etc/fstab

# chroot
arch-chroot /mnt /bin/bash <<EOF
# set initial hostname
echo "archlinux-$(date -I)" >/etc/hostname
# set initial timezone to America/Chicago
ln -s /usr/share/zoneinfo/America/Chicago /etc/localtime
# set initial locale
locale >/etc/locale.conf
echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
echo "en_US ISO-8859-1" >>/etc/locale.gen
locale-gen
# no modifications to mkinitcpio.conf should be needed
mkinitcpio -p linux
# install syslinux bootloader
syslinux-install_update -i -a -m
# update syslinux config with correct root disk
sed 's/root=.*/root=\/dev\/sda2 ro/' < /boot/syslinux/syslinux.cfg > /boot/syslinux/syslinux.cfg.new
mv /boot/syslinux/syslinux.cfg.new /boot/syslinux/syslinux.cfg
# set root password to "root"
echo root:root | chpasswd
# end section sent to chroot
EOF

# unmount
umount /mnt/{boot,}

echo "Done! Unmount the CD image from the VM, then type 'reboot'."
