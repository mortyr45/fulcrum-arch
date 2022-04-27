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

fn_generate_hook_post_crypttab_initramfs() {
    DRIVE_UUID=$(blkid -s UUID -o value $1)
    echo "luks_root /dev/disk/by-uuid/$DRIVE_UUID none defaults" > /mnt/etc/crypttab.initramfs
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
    fn_create_boot_partition $DRIVE_TO_USE
    mkfs.ext4 "${DRIVE_TO_USE}2"
    fn_create_linux_partition $DRIVE_TO_USE
    mkfs.btrfs "${DRIVE_TO_USE}3"
    fn_setup_btrfs_subvolumes "${DRIVE_TO_USE}3" "${DRIVE_TO_USE}2" "${DRIVE_TO_USE}1"
}

fn_encrypted_btrfs() {
    DRIVE_TO_USE="/dev/sda"
    read -p "Which drive to use? [$DRIVE_TO_USE]: "
    ! [ -z $REPLY ] && DRIVE_TO_USE=$REPLY

    fn_create_gpt_layout $DRIVE_TO_USE
    fn_create_efi_partition $DRIVE_TO_USE
    mkfs.fat -F 32 "${DRIVE_TO_USE}1"
    fn_create_boot_partition $DRIVE_TO_USE
    mkfs.ext4 "${DRIVE_TO_USE}2"
    fn_create_linux_partition $DRIVE_TO_USE
    cryptsetup luksFormat "${DRIVE_TO_USE}3"
    cryptsetup open "${DRIVE_TO_USE}3" luks_root
    mkfs.btrfs /dev/mapper/luks_root
    fn_setup_btrfs_subvolumes /dev/mapper/luks_root "${DRIVE_TO_USE}2" "${DRIVE_TO_USE}1"
    fn_generate_hook_post_grub "${DRIVE_TO_USE}3"
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
esac