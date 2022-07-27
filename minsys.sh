#!/bin/bash

pacman --noconfirm -Sy archlinux-keyring && pacman-key --populate archlinux
pacstrap /mnt base btrfs-progs cronie dkms grub linux linux-headers linux-firmware mkinitcpio nano networkmanager sudo which
echo "Defaults editor=/usr/bin/rnano" >> /mnt/etc/sudoers
arch-chroot /mnt sed -ri -e "s/^#.*%wheel ALL=\(ALL:ALL\) ALL/%wheel ALL=(ALL:ALL) ALL/g" /etc/sudoers
while true ; do
    read -p "Username: "
    ! [ -z $REPLY ] && break
done
USERNAME=$REPLY
arch-chroot /mnt useradd -m -G wheel $REPLY
while true ; do
    while true ; do
        read -sp "Password: "
        ! [ -z $REPLY ] && break
    done
    PASSWORD=$REPLY
    read -sp "Re-enter password: "
    [ $PASSWORD == $REPLY ] && break
done
echo $USERNAME:$PASSWORD | arch-chroot /mnt chpasswd
