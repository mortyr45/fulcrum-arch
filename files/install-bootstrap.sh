#!/bin/bash

timedatectl set-ntp true
case $SCRIPT_CPU_MITIGATIONS in
  0)
    SCRIPT_CPU_MITIGATIONS="" ;;
  1)
    SCRIPT_CPU_MITIGATIONS="amd-ucode" ;;
  2)
    SCRIPT_CPU_MITIGATIONS="intel-ucode" ;;
esac
pacstrap /mnt base btrfs-progs nano grub efibootmgr os-prober sudo $SCRIPT_CPU_MITIGATIONS
genfstab -U /mnt > /mnt/etc/fstab

while true ; do
  read -p "Username:
  ! [ -z $REPLY ] && break
done
SCRIPT_USERNAME=$REPLY

while true ; do
  read -sp "Password:"
  ! [ -z $REPLY ] && break
done
SCRIPT_PASSWORD=$REPLY

echo "$SCRIPT_USERNAME:$SCRIPT_PASSWORD"
