#!/bin/bash

fn_create_gpt_layout {
    echo $1
}
#fn_create_efi_partition {}
#fn_create_boot_partition {}
#fn_create_btrfs_partition {}
#fn_create_luks_partition {}

fn_simple_btrfs {
    echo $1
    fn_create_gpt_layout "called by simple btrfs"
fdisk /dev/sda <<EOF
g
n


+500M
t
1
n



w
EOF
}

REPLY="1"
echo "1) Simple btrfs (1 EFI partition and 1 btrfs partition)"
echo "2) Encrypted btrfs (1 EFI partition and 1 encrypted btrfs partition)"
echo "3) Encrypted btrfs with detached header (1 EFI partition, 1 /boot partition and 1 encrypted btrfs partition)"
read -p "Choose disk setup method [$REPLY]: "

case $REPLY in
    1)
        fn_simple_btrfs "called by main thingy" ;;
    2)
        #fn_encrypted_btrfs ;;
    3)
        #fn_detached_encrypted_btrfs ;;
esac