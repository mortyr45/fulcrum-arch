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
  read -p "Username: "
  ! [ -z $REPLY ] && break
done
SCRIPT_USERNAME=$REPLY

while true ; do
  while true ; do
    read -sp "Password: "
    ! [ -z $REPLY ] && break
  done
  SCRIPT_PASSWORD=$REPLY
  read -sp "Re-enter password: "
  [ $SCRIPT_PASSWORD == $REPLY ] && break
done

arch-chroot /mnt useradd -m -G wheel $SCRIPT_USERNAME
echo $SCRIPT_USERNAME:$SCRIPT_PASSWORD | arch-chroot /mnt chpasswd

arch-chroot /mnt ln -sf /usr/share/zoneinfo/$SCRIPT_TIMEZONE /etc/localtime
arch-chroot /mnt sed -ri -e "s!^#$SCRIPT_LOCALE!$SCRIPT_LOCALE!g" /etc/locale.gen
arch-chroot /mnt locale-gen
echo "$SCRIPT_HOSTNAME" > /mnt/etc/hostname
arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=$SCRIPT_BOOTLOADER_ID
arch-chroot /mnt cp /usr/share/locale/$SCRIPT_GRUB_LANG\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/$SCRIPT_GRUB_LANG.mo
