#!/bin/bash

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