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

arch-chroot /mnt sed -ri -e "s!*GRUB_TIMEOUT=!GRUB_TIMEOUT=3!g" /etc/default/grub
arch-chroot /mnt sed -ri -e "s!*GRUB_DEFAULT=!GRUB_DEFAULT=saved!g" /etc/default/grub
arch-chroot /mnt sed -ri -e "s!*GRUB_SAVEDEFAULT=!GRUB_SAVEDEFAULT=true!g" /etc/default/grub
