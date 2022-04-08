#!/bin/bash

! [ -f "install-finish.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/install-finish.sh > install-finish.sh

INSTALL_FILES=("prompt" "partitions" "bootstrap" "kernel")
for FILE in ${INSTALL_FILES[@]} ; do
  ! [ -f "install-$FILE.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/install-$FILE.sh > install-$FILE.sh
done
for FILE in ${INSTALL_FILES[@]} ; do
  source $FILE.sh
  [ $? != 0 ] && exit 1
done

CHROOT_INSTALL_FILES=("base")
for FILE in ${CHROOT_INSTALL_FILES[@]} ; do
  ! [ -f "install-$FILE.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/install-chroot-$FILE.sh > /mnt/$FILE.sh
  [ $? != 0 ] && exit 1
  chmod +x /mnt/$FILE.sh
done

sed -ri -e "s!^SCRIPT_TIMEZONE=!SCRIPT_TIMEZONE=$SCRIPT_TIMEZONE!g" /mnt/base.sh
sed -ri -e "s!^SCRIPT_LOCALE=!SCRIPT_LOCALE=$SCRIPT_LOCALE!g" /mnt/base.sh
sed -ri -e "s!^SCRIPT_HOSTNAME=!SCRIPT_HOSTNAME=$SCRIPT_HOSTNAME!g" /mnt/base.sh
sed -ri -e "s!^SCRIPT_BOOTLOADER_ID=!SCRIPT_BOOTLOADER_ID=$SCRIPT_BOOTLOADER_ID!g" /mnt/base.sh
sed -ri -e "s!^SCRIPT_GRUB_LANG=!SCRIPT_GRUB_LANG=$SCRIPT_GRUB_LANG!g" /mnt/base.sh

arch-chroot /mnt ./base.sh

arch-chroot /mnt

source install-finish.sh
