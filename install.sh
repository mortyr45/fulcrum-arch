#!/bin/bash

INSTALL_FILES=("prompt" "partitions" "kernel")

for FILE in ${INSTALL_FILES[@]} ; do
  ! [ -f "install-$FILE.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/install-$FILE.sh > install-$FILE.sh
  [ $? != 0 ] && exit 1
done

source install-prompt.sh
[ $? != 0 ] && exit 1
source install-partitions.sh
[ $? != 0 ] && exit 1

timedatectl set-ntp true
pacstrap /mnt base btrfs-progs nano grub efibootmgr os-prober
genfstab -U /mnt > /mnt/etc/fstab

source install-kernel.sh

CHROOT_INSTALL_FILES=("base")
for FILE in ${CHROOT_INSTALL_FILES[@]} ; do
  ! [ -f "install-$FILE.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/install-chroot-$FILE.sh > /mnt/$FILE.sh
  [ $? != 0 ] && exit 1
  chmod +x /mnt/$FILE.sh
done

sed -ri -e "s!^SCRIPT_TIMEZONE=!SCRIPT_TIMEZONE=$SCRIPT_TIMEZONE!g" /mnt/base.sh
sed -ri -e "s!^SCRIPT_HOSTNAME=!SCRIPT_HOSTNAME=$SCRIPT_HOSTNAME!g" /mnt/base.sh
sed -ri -e "s!^SCRIPT_BOOTLOADER_ID=!SCRIPT_BOOTLOADER_ID=$SCRIPT_BOOTLOADER_ID!g" /mnt/base.sh
sed -ri -e "s!^SCRIPT_GRUB_LANG=!SCRIPT_GRUB_LANG=$SCRIPT_GRUB_LANG!g" /mnt/base.sh

arch-chroot /mnt
