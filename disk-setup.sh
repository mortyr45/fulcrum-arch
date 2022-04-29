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

#####
# Helper functions
#####

fn_setup_btrfs_subvolumes() {
    BTRFS_PARTITION=$1
    BOOT_PARTITION=$2
    EFI_PARTITION=$3
    mount $BTRFS_PARTITION /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@cache
    btrfs subvolume create /mnt/@log
    umount /mnt
cat > pre-install-hook.sh<< EOF
#!/bin/bash

mount $BTRFS_PARTITION -o subvol=@ /mnt
mount --mkdir $BTRFS_PARTITION -o subvol=@home /mnt/home
mount --mkdir $BTRFS_PARTITION -o subvol=@cache /mnt/var/cache
mount --mkdir $BTRFS_PARTITION -o subvol=@log /mnt/var/log
mount --mkdir $BOOT_PARTITION /mnt/boot
mount --mkdir $EFI_PARTITION /mnt/boot/EFI
EOF
}

fn_generate_hook_post_grub() {
    PARTITION_UUID=$(blkid -s UUID -o value $1)
    echo "sed -ri -e \"s/^.*GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/g\" /mnt/etc/default/grub" >> post-install-hook.sh
    echo "echo \"luks_boot $PARTITION_UUID q luks\" >> /mnt/etc/crypttab" >> post-install-hook.sh
    #echo "sed -ri -e \"s/^.*GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX='cryptdevice=UUID=$PARTITION_UUID:luks_boot'/g\" /mnt/etc/default/grub" >> post-install-hook.sh
}

fn_generate_hook_post_crypttab_initramfs() {
    PARTITION_PATH=$(ls -l /dev/disk/by-path | grep $1 | cut -d ' ' -f 9)
    CRYPT_OPTION="luks"
    ! [ -z $2 ] && CRYPT_OPTION+=",header=/luks_root_header.img:UUID=$2"
    echo "echo \"luks_root /dev/disk/by-path/$PARTITION_PATH none $CRYPT_OPTION\" > /mnt/etc/crypttab.initramfs" >> post-install-hook.sh
}

#####
# Control functions
#####

fn_setup_disks() {
    EFI_PARTITION="sda1"
    read -p "Which partition is to be used for EFI? [$EFI_PARTITION]: "
    ! [ -z $REPLY ] && EFI_PARTITION=$REPLY
    EFI_PATH="/dev/$EFI_PARTITION"
    mkfs.fat -F 32 $EFI_PATH

    BOOT_PARTITION="sda2"
    read -p "Which partition is to be used for /boot? [$BOOT_PARTITION]: "
    ! [ -z $REPLY ] && BOOT_PARTITION=$REPLY
    read -p "Encrypt /boot partition? [y/N]: "
    ! [ -z $REPLY ] && ENCRYPT_BOOT_PARTITION=$REPLY

    if [ "$ENCRYPT_BOOT_PARTITION" == "y" ] ; then
        cryptsetup luksFormat --type luks1 /dev/$BOOT_PARTITION
        cryptsetup open /dev/$BOOT_PARTITION luks_boot
        BOOT_PATH="/dev/mapper/luks_boot"
        fn_generate_hook_post_grub $BOOT_PATH
    else
        BOOT_PATH="/dev/$BOOT_PARTITION"
    fi
    mkfs.ext4 $BOOT_PATH

    ROOT_PARTITION="sda3"
    read -p "Which partition is to be used for root? [$ROOT_PARTITION]: "
    ! [ -z $REPLY ] && ROOT_PARTITION=$REPLY
    read -p "Encrypt root partition? [y/N]: "
    ! [ -z $REPLY ] && ENCRYPT_ROOT_PARTITION=$REPLY

    if [ "$ENCRYPT_ROOT_PARTITION" == "y" ] ; then
        read -p "Detach encryption header for root partition? [y/N]: "
        ! [ -z $REPLY ] && DETACH_HEADER=$REPLY

        if [ "$DETACH_HEADER" == "y" ] ; then
            cryptsetup luksFormat /dev/$ROOT_PARTITION --offset 32768 --header luks_root_header.img
            cryptsetup open --header luks_root_header.img /dev/$ROOT_PARTITION luks_root
            BOOT_UUID=$(blkid -s UUID -o value $BOOT_PATH)
            fn_generate_hook_post_crypttab_initramfs $ROOT_PARTITION $BOOT_UUID
        else
            cryptsetup luksFormat /dev/$ROOT_PARTITION
            cryptsetup open /dev/$ROOT_PARTITION luks_root
            fn_generate_hook_post_crypttab_initramfs $ROOT_PARTITION
        fi
        
        ROOT_PATH="/dev/mapper/luks_root"
    else
        ROOT_PATH="/dev/$ROOT_PARTITION"
    fi
    mkfs.btrfs $ROOT_PATH

    fn_setup_btrfs_subvolumes $ROOT_PATH $BOOT_PATH $EFI_PATH
}

fn_simple_btrfs() {
    DRIVE_TO_USE="/dev/sda"
    read -p "Which drive to use? [$DRIVE_TO_USE]: "
    ! [ -z $REPLY ] && DRIVE_TO_USE=$REPLY

    fn_create_gpt_layout $DRIVE_TO_USE
    fn_create_efi_partition $DRIVE_TO_USE
    mkfs.fat -F 32 "${DRIVE_TO_USE}1"
    fn_create_boot_partition $DRIVE_TO_USE
    mkfs.ext4 "${DRIVE_TO_USE}2"
    fn_create_linux_partition $DRIVE_TO_USE
    mkfs.btrfs "${DRIVE_TO_USE}3"
    fn_setup_btrfs_subvolumes "${DRIVE_TO_USE}3" "${DRIVE_TO_USE}2" "${DRIVE_TO_USE}1"
}

fn_encrypted_btrfs() {
    DRIVE_TO_USE="sda"
    read -p "Which drive to use? [$DRIVE_TO_USE]: "
    ! [ -z $REPLY ] && DRIVE_TO_USE=$REPLY
    FULL_DRIVE="/dev/$DRIVE_TO_USE"

    fn_create_gpt_layout $FULL_DRIVE
    fn_create_efi_partition $FULL_DRIVE
    mkfs.fat -F 32 "${FULL_DRIVE}1"
    fn_create_boot_partition $FULL_DRIVE
    mkfs.ext4 "${FULL_DRIVE}2"
    fn_create_linux_partition $FULL_DRIVE
    cryptsetup luksFormat "${FULL_DRIVE}3"
    cryptsetup open "${FULL_DRIVE}3" luks_root
    mkfs.btrfs /dev/mapper/luks_root
    fn_setup_btrfs_subvolumes /dev/mapper/luks_root "${FULL_DRIVE}2" "${FULL_DRIVE}1"
    fn_generate_hook_post_crypttab_initramfs "${DRIVE_TO_USE}3"
}

DISK_SETUP_CHOICE="1"
echo "1) Simple btrfs (1 EFI partition, 1 /boot partition and 1 btrfs partition)"
echo "2) Encrypted btrfs (1 EFI partition, 1 /boot partition and 1 encrypted btrfs partition)"
echo "3) Encrypted btrfs with detached header (1 EFI partition, 1 /boot partition and 1 encrypted btrfs partition with detached luks header)"
read -p "Choose disk setup method [$DISK_SETUP_CHOICE]: "
! [ -z $REPLY ] && DISK_SETUP_CHOICE=$REPLY

case $DISK_SETUP_CHOICE in
    1)
        fn_simple_btrfs ;;
    2)
        fn_encrypted_btrfs ;;
    3)
        fn_detached_encrypted_btrfs ;;
    4)
        fn_setup_disks ;;
esac