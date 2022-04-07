#!/bin/bash

# For personal use only. No warranties of any kind if you use it!

clear

EFI_INSTALL=0
ls /sys/firmware/efi/efivars > /dev/null
if [ $? == 0 ] ; then
  EFI_INSTALL=1
fi

EFI_PARTITION=/dev/sda1
echo -n "Device and partition number for EFI[$EFI_PARTITION]:"
read;
if ! [ -z $REPLY ] ; then EFI_PARTITION=$REPLY ; fi

ROOT_PARTITION=/dev/sda2
echo -n "Device and partition number for root[$ROOT_PARTITION]:"
read;
if ! [ -z $REPLY ] ; then ROOT_PARTITION=$REPLY ; fi

SCRIPT_TIMEZONE_REGION=Europe
ls /usr/share/zoneinfo
echo -n "Time zone region[$SCRIPT_TIMEZONE_REGION]:"
read;
if ! [ -z $REPLY ] ; then SCRIPT_TIMEZONE_REGION=$REPLY ; fi

SCRIPT_TIMEZONE_CITY=Budapest
ls /usr/share/zoneinfo/$SCRIPT_TIMEZONE_REGION
echo -n "Time zone region[$SCRIPT_TIMEZONE_CITY]:"
read;
if ! [ -z $REPLY ] ; then SCRIPT_TIMEZONE_CITY=$REPLY ; fi

SCRIPT_TIMEZONE="$SCRIPT_TIMEZONE_REGION/$SCRIPT_TIMEZONE_CITY"

clear
echo "EFI partition: $EFI_PARTITION"
echo "Root partition: ROOT_PARTITION"
echo "Timezone: $SCRIPT_TIMEZONE"
echo -n "Are the settings correct?[y/n]"
read;
if [ $REPLY != "y" ] ; then exit 0 ; fi

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
chmod +x /mnt/install.sh
arch-chroot /mnt ./install.sh
