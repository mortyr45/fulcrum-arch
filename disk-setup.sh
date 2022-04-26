#!/bin/bash

#####
# Partition tables, partition creation
#####

fn_create_gpt_layout() {
fdisk $1 <<EOF
g
w
EOF
}

fn_create_efi_partition() {
fdisk $1 <<EOF
n


+500M
t
1
w
EOF
}

fn_create_boot_partition() {
fdisk $1 <<EOF
n


+1G
w
EOF
}

fn_create_linux_partition() {
fdisk $1 <<EOF
n



w
EOF
}

fn_create_luks_partition() {}

#####
# Helper functions
#####

fn_setup_btrfs_subvolumes() {
    mount /dev/sda2 /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@cache
    btrfs subvolume create /mnt/@log
    umount /mnt
    mount /dev/sda2 -o subvol=@ /mnt
    mount --mkdir /dev/sda2 -o subvol=@home /mnt/home
    mount --mkdir /dev/sda2 -o subvol=@cache /mnt/var/cache
    mount --mkdir /dev/sda2 -o subvol=@log /mnt/var/log
    mount --mkdir /dev/sda1 /mnt/boot/EFI
}

#####
# Control functions
#####

fn_simple_btrfs() {
    DRIVE_TO_USE="/dev/sda"
    read -p "Which drive to use? [$DRIVE_TO_USE]: "
    ! [ -z $REPLY ] && DRIVE_TO_USE=$REPLY
    fn_create_gpt_layout $DRIVE_TO_USE
    fn_create_efi_partition $DRIVE_TO_USE
    mkfs.fat -F 32 "${DRIVE_TO_USE}1"
    fn_create_linux_partition $DRIVE_TO_USE
    mkfs.btrfs "${DRIVE_TO_USE}2"
    fn_setup_btrfs_subvolumes "${DRIVE_TO_USE}2"
}

DISK_SETUP_CHOICE="1"
echo "1) Simple btrfs (1 EFI partition and 1 btrfs partition)"
echo "2) Encrypted btrfs (1 EFI partition and 1 encrypted btrfs partition)"
echo "3) Encrypted btrfs with detached header (1 EFI partition, 1 /boot partition and 1 encrypted btrfs partition)"
read -p "Choose disk setup method [$DISK_SETUP_CHOICE]: "
! [ -z $REPLY ] && DISK_SETUP_CHOICE=$REPLY

case $DISK_SETUP_CHOICE in
    1)
        fn_simple_btrfs ;;
    2)
        fn_encrypted_btrfs ;;
    3)
        fn_detached_encrypted_btrfs ;;
esac