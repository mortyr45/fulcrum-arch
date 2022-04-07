#!/bin/bash

INSTALL_FILES=("prompt" "partitions")

for FILE in $INSTALL_FILES ; do
  ! [ -f "install-$FILE.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/install-$FILE.sh > install-$FILE.sh
done

for FILE in $INSTALL_FILES ; do
  source install-$FILE.sh
done

timedatectl set-ntp true
pacstrap /mnt base linux linux-firmware linux-headers btrfs-progs nano grub efibootmgr os-prober
genfstab -U /mnt > /mnt/etc/fstab

curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/chroot.sh >> /mnt/install.sh
sed -ri -e "s!^SCRIPT_TIMEZONE=!SCRIPT_TIMEZONE=$SCRIPT_TIMEZONE!g" /mnt/install.sh
sed -ri -e "s!^SCRIPT_HOSTNAME=!SCRIPT_HOSTNAME=$SCRIPT_HOSTNAME!g" /mnt/install.sh
sed -ri -e "s!^SCRIPT_BOOTLOADER_ID=!SCRIPT_BOOTLOADER_ID=$SCRIPT_BOOTLOADER_ID!g" /mnt/install.sh
sed -ri -e "s!^SCRIPT_GRUB_LANG=!SCRIPT_GRUB_LANG=$SCRIPT_GRUB_LANG!g" /mnt/install.sh
chmod +x /mnt/install.sh
arch-chroot /mnt ./install.sh
