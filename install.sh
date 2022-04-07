#!/bin/bash

! [ -f "install-prompt.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/install-prompt.sh > install-prompt.sh
! [ -f "install-partitions.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/install-partitions.sh > install-partitions.sh

source install-prompt.sh

source install-partitions.sh

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
