#!/bin/bash

#####
# Helper functions
#####

fn_setup_btrfs_subvolumes() {
    if [ -z $3 ] ; then
        BTRFS_PARTITION=$1
        EFI_PARTITION=$2
    else
        BTRFS_PARTITION=$1
        BOOT_PARTITION=$2
        EFI_PARTITION=$3
    fi
    mount $BTRFS_PARTITION /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@cache
    btrfs subvolume create /mnt/@log
    umount /mnt
    mount $BTRFS_PARTITION -o subvol=@ /mnt
    mount --mkdir $BTRFS_PARTITION -o subvol=@home /mnt/home
    mount --mkdir $BTRFS_PARTITION -o subvol=@cache /mnt/var/cache
    mount --mkdir $BTRFS_PARTITION -o subvol=@log /mnt/var/log
    ! [ -z $3 ] && mount --mkdir $BOOT_PARTITION /mnt/boot
    mount --mkdir $EFI_PARTITION /mnt/boot/EFI
}

#####
# Control functions
#####

fn_setup_efi_partition() {
    EFI_PARTITION="sda1"
    read -p "Which partition is to be used for EFI? [$EFI_PARTITION]: "
    ! [ -z $REPLY ] && EFI_PARTITION=$REPLY
    EFI_PATH="/dev/$EFI_PARTITION"
    mkfs.fat -F 32 $EFI_PATH
}

fn_setup_boot_partition() {
    BOOT_PARTITION="sda2"
    read -p "Which partition is to be used for /boot? [$BOOT_PARTITION]: "
    ! [ -z $REPLY ] && BOOT_PARTITION=$REPLY
    BOOT_PATH="/dev/$BOOT_PARTITION"
    mkfs.ext4 $BOOT_PATH
}

fn_setup_encrypted_root() {
    cryptsetup luksFormat --type luks1 /dev/$ROOT_PARTITION
    cryptsetup open /dev/$ROOT_PARTITION luks_root
    ROOT_UUID=$(blkid -s UUID -o value /dev/$ROOT_PARTITION)
    echo "dd if=/dev/urandom of=/mnt/crypto_keyfile.bin bs=1024 count=4" >> post-install-hook.sh
    echo "chmod 400 /mnt/crypto_keyfile.bin" >> post-install-hook.sh
    echo "cryptsetup luksAddKey /dev/$ROOT_PARTITION /mnt/crypto_keyfile.bin" >> post-install-hook.sh
    echo "echo \"luks_root /dev/disk/by-uuid/$ROOT_UUID /crypto_keyfile.bin luks \" > /mnt/etc/crypttab.initramfs" >> post-install-hook.sh
    echo "sed -ri -e \"s/^FILES=.*/FILES=(\/crypto_keyfile.bin)/g\" /mnt/etc/mkinitcpio.conf"  >> post-install-hook.sh
    echo "sed -ri -e \"s/^#GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/g\" /mnt/etc/default/grub" >> post-install-hook.sh
}

fn_setup_encrypted_root_separate() {
    cryptsetup luksFormat /dev/$ROOT_PARTITION
    cryptsetup open /dev/$ROOT_PARTITION luks_root
    ROOT_UUID=$(blkid -s UUID -o value /dev/$ROOT_PARTITION)
    echo "echo \"luks_root /dev/disk/by-uuid/$ROOT_UUID none luks\" > /mnt/etc/crypttab.initramfs" >> post-install-hook.sh
}

fn_setup_encrypted_root_detached() {
    dd if=/dev/zero of=luks_root_header.img bs=16M count=1
    cryptsetup luksFormat /dev/$ROOT_PARTITION --offset 32768 --header luks_root_header.img
    cryptsetup open --header luks_root_header.img /dev/$ROOT_PARTITION luks_root
    BOOT_UUID=$(blkid -s UUID -o value $BOOT_PATH)
    PARTITION_PATH=$(ls -l /dev/disk/by-path | grep $ROOT_PARTITION | cut -d ' ' -f 9)
    echo "echo \"luks_root /dev/disk/by-path/$PARTITION_PATH none luks,header=/luks_root_header.img:UUID=$BOOT_UUID\" > /mnt/etc/crypttab.initramfs" >> post-install-hook.sh
    echo "cp luks_root_header.img /mnt/boot" >> post-install-hook.sh
}

fn_setup_disks() {
    fn_setup_efi_partition

    SEPARATE_BOOT_PARTITION="y"
    read -p "Would you like to use a separate /boot partition? [Y/n]: "
    ! [ -z $REPLY ] && SEPARATE_BOOT_PARTITION=$REPLY
    [ "$SEPARATE_BOOT_PARTITION" == "y" ] && fn_setup_boot_partition

    ROOT_PARTITION="sda3"
    read -p "Which partition is to be used for root? [$ROOT_PARTITION]: "
    ! [ -z $REPLY ] && ROOT_PARTITION=$REPLY
    read -p "Encrypt root partition? [y/N]: "
    ! [ -z $REPLY ] && ENCRYPT_ROOT_PARTITION=$REPLY

    if [ "$ENCRYPT_ROOT_PARTITION" == "y" ] ; then
        if [ "$SEPARATE_BOOT_PARTITION" == "y" ] ; then
            read -p "Detach encryption header for root partition? [y/N]: "
            ! [ -z $REPLY ] && DETACH_HEADER=$REPLY

            if [ "$DETACH_HEADER" == "y" ] ; then
                fn_setup_encrypted_root_detached
            else
                fn_setup_encrypted_root_separate
            fi
        else
            fn_setup_encrypted_root
        fi
        
        ROOT_PATH="/dev/mapper/luks_root"
    else
        ROOT_PATH="/dev/$ROOT_PARTITION"
    fi
    mkfs.btrfs $ROOT_PATH

    if [ "$SEPARATE_BOOT_PARTITION" == "y" ] ; then
        fn_setup_btrfs_subvolumes $ROOT_PATH $BOOT_PATH $EFI_PATH
    else
        fn_setup_btrfs_subvolumes $ROOT_PATH $EFI_PATH
    fi
}

fn_setup_disks
