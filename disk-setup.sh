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
    EFI_PARTITION=$2
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
mount --mkdir $EFI_PARTITION /mnt/boot/EFI
EOF
}

fn_generate_hook_post_grub() {
    DRIVE_UUID=$(blkid -s UUID -o value $1)
cat > post-install-hook.sh<< EOF
arch-chroot /mnt sed -ri -e "s/^.*GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/g" /etc/default/grub
arch-chroot /mnt sed -ri -e "s/^.*GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$DRIVE_UUID:luks_root\"/g" /etc/default/grub
EOF
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
    fn_setup_btrfs_subvolumes "${DRIVE_TO_USE}2" "${DRIVE_TO_USE}1"
}

fn_encrypted_btrfs() {
    DRIVE_TO_USE="/dev/sda"
    read -p "Which drive to use? [$DRIVE_TO_USE]: "
    ! [ -z $REPLY ] && DRIVE_TO_USE=$REPLY

    fn_create_gpt_layout $DRIVE_TO_USE
    fn_create_efi_partition $DRIVE_TO_USE
    mkfs.fat -F 32 "${DRIVE_TO_USE}1"
    fn_create_linux_partition $DRIVE_TO_USE
    cryptsetup -y --type luks1 luksFormat "${DRIVE_TO_USE}2"
    cryptsetup open "${DRIVE_TO_USE}2" luks_root
    mkfs.btrfs /dev/mapper/luks_root
    fn_setup_btrfs_subvolumes /dev/mapper/luks_root "${DRIVE_TO_USE}1"
    fn_generate_hook_post_grub "${DRIVE_TO_USE}2"
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