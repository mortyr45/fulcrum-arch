#!/bin/bash

INSTALL_FILES=("prompt" "partitions")

for FILE in ${INSTALL_FILES[@]} ; do
  ! [ -f "install-$FILE.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/install-$FILE.sh > install-$FILE.sh
  [ $? != 0 ] && exit 1
done

for FILE in ${INSTALL_FILES[@]} ; do
  source install-$FILE.sh
  [ $? != 0 ] && exit 1
done

timedatectl set-ntp true
pacstrap /mnt base btrfs-progs nano grub efibootmgr os-prober
genfstab -U /mnt > /mnt/etc/fstab

clear
printf "Which kernel(s) would you like to install?\n1) linux\n2) linux-lts\n3) linux-hardened\n4) linux-zen\n"
echo -n "Choose multiple of them, by separating the numbers with a ','[1]: "
read;
if [ -z $REPLY ] ; then
  arch-chroot /mnt "pacman -S linux linux-firmware linux-headers"
else
  TEMP=""
  IFS=","
  for KERNEL in $REPLY ; do
    case $KERNEL in
    1)
      TEMP+=" linux linux-firmware linux-headers" ;;
    2)
      TEMP+=" linux-lts linux-lts-firmware linux-lts-headers" ;;
    3)
      TEMP+=" linux-hardened linux-hardened-firmware linux-hardened-headers" ;;
    4)
      TEMP+=" linux-zen linux-zen-firmware linux-zen-headers" ;;
  done
  arch-chroot /mnt pacman --noconfirm -S $TEMP
fi

CHROOT_INSTALL_FILES=("base")
for FILE in ${CHROOT_INSTALL_FILES} ; do
  ! [ -f "install-$FILE.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/install-chroot-$FILE.sh > /mnt/install-$FILE.sh
  [ $? != 0 ] && exit 1
  chmod +x /mnt/install-$FILE.sh
done

sed -ri -e "s!^SCRIPT_TIMEZONE=!SCRIPT_TIMEZONE=$SCRIPT_TIMEZONE!g" /mnt/install-chroot-base.sh
sed -ri -e "s!^SCRIPT_HOSTNAME=!SCRIPT_HOSTNAME=$SCRIPT_HOSTNAME!g" /mnt/install-chroot-base.sh
sed -ri -e "s!^SCRIPT_BOOTLOADER_ID=!SCRIPT_BOOTLOADER_ID=$SCRIPT_BOOTLOADER_ID!g" /mnt/install-chroot-base.sh
sed -ri -e "s!^SCRIPT_GRUB_LANG=!SCRIPT_GRUB_LANG=$SCRIPT_GRUB_LANG!g" /mnt/install-chroot-base.sh

arch-chroot /mnt
