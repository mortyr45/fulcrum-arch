#!/bin/bash

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
    PARTITION_PATH=$(ls -l /dev/disk/by-path | grep $1 | cut -d ' ' -f 9)
    CRYPT_OPTION="luks"
    ! [ -z $2 ] && CRYPT_OPTION="header=/luks_root_header.img:UUID=$2"
    echo "echo \"luks_root /dev/disk/by-path/$PARTITION_PATH none $CRYPT_OPTION\" > /mnt/etc/crypttab.initramfs" >> post-install-hook.sh
    ! [ -z $2 ] && echo "mv luks_root_header.img /mnt/boot" >> pre-install-hook.sh
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

    BOOT_PATH="/dev/$BOOT_PARTITION"
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
            dd if=/dev/zero of=luks_root_header.img bs=16M count=1
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

fn_setup_disks
