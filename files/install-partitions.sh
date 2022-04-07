#!/bin/bash

mkfs.fat -F 32 $SCRIPT_EFI_PARTITION
if [ $SCRIPT_ROOT_PARTITION_SSD ] ; then
  mkfs.btrfs -m single -d single $SCRIPT_ROOT_PARTITION
else
  mkfs.btrfs -m dup -d single $SCRIPT_ROOT_PARTITION
fi
mount $SCRIPT_ROOT_PARTITION /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@log
umount /mnt
mount $SCRIPT_ROOT_PARTITION -o subvol=@ /mnt
mount --mkdir $SCRIPT_ROOT_PARTITION -o subvol=@home /mnt/home
mount --mkdir $SCRIPT_ROOT_PARTITION -o subvol=@cache /mnt/var/cache
mount --mkdir $SCRIPT_ROOT_PARTITION -o subvol=@log /mnt/var/log
mount --mkdir $SCRIPT_EFI_PARTITION /mnt/boot/EFI
