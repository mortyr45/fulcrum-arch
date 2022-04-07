#!/bin/bash

if ! [ -f "install-prompt.sh" ]
  curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/install-prompt.sh > install-prompt.sh
 fi

source install-prompt.sh

timedatectl set-ntp true

mkfs.fat -F 32 $EFI_PARTITION
mkfs.btrfs $ROOT_PARTITION
mount $ROOT_PARTITION /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@log
umount /mnt
mount $ROOT_PARTITION -o subvol=@ /mnt
mount --mkdir $ROOT_PARTITION -o subvol=@home /mnt/home
mount --mkdir $ROOT_PARTITION -o subvol=@cache /mnt/var/cache
mount --mkdir $ROOT_PARTITION -o subvol=@log /mnt/var/log
mount --mkdir $EFI_PARTITION /mnt/boot/EFI

pacstrap /mnt base linux linux-firmware linux-headers btrfs-progs nano grub efibootmgr os-prober
genfstab -U /mnt > /mnt/etc/fstab

curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/chroot.sh >> /mnt/install.sh
sed -ri -e "s!^SCRIPT_TIMEZONE=!SCRIPT_TIMEZONE=$SCRIPT_TIMEZONE!g" /mnt/install.sh
sed -ri -e "s!^SCRIPT_HOSTNAME=!SCRIPT_HOSTNAME=$SCRIPT_HOSTNAME!g" /mnt/install.sh
sed -ri -e "s!^SCRIPT_BOOTLOADER_ID=!SCRIPT_BOOTLOADER_ID=$SCRIPT_BOOTLOADER_ID!g" /mnt/install.sh
sed -ri -e "s!^SCRIPT_GRUB_LANG=!SCRIPT_GRUB_LANG=$SCRIPT_GRUB_LANG!g" /mnt/install.sh
chmod +x /mnt/install.sh
arch-chroot /mnt ./install.sh
