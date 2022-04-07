#!/bin/bash

mkfs.fat -F 32 $EFI_PARTITION
while true ; do
  echo -n "Is the root partition on an ssd?[y/n]"
  read;
  ! [ -z $REPLY ] && break
do
if [ $REPLY == "y" ] ; then
  mkfs.btrfs -m single -d single $ROOT_PARTITION
else
  mkfs.btrfs -m dup -d single $ROOT_PARTITION
fi
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

genfstab -U /mnt > /mnt/etc/fstab
