#!/bin/bash

### Packages
pacman --noconfirm -Sy archlinux-keyring && pacman-key --populate archlinux
pacstrap /mnt base btrfs-progs cronie dkms efibootmgr grub linux linux-headers linux-firmware mkinitcpio nano networkmanager pacman-contrib sudo which
genfstab -U /mnt > /mnt/etc/fstab
echo "Defaults editor=/usr/bin/rnano" >> /mnt/etc/sudoers
sed -ri -e "s/^#.*%wheel ALL=\(ALL:ALL\) ALL/%wheel ALL=(ALL:ALL) ALL/g" /mnt/etc/sudoers
arch-chroot /mnt systemctl enable NetworkManager.service
arch-chroot /mnt systemctl enable cronie.service

### User
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

### Basic system config
systemd-firstboot --force --root=/mnt --prompt-locale --prompt-keymap --prompt-timezone --prompt-hostname
sed -ri -e "s/^HOOKS=.*/HOOKS=\(systemd\ keyboard\ modconf\ block\ sd-encrypt\ fsck\ filesystems\)/g" /mnt/etc/mkinitcpio.conf
sed -ri -e '/^\#fallback_config/,$ d' /mnt/etc/mkinitcpio.d/linux.preset
rm /mnt/boot/initramfs-linux-fallback.img
arch-chroot /mnt mkinitcpio -P
sed -ri -e "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/g" /mnt/etc/default/grub
sed -ri -e "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=3/g" /mnt/etc/default/grub
sed -ri -e "s/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/g" /mnt/etc/default/grub
sed -ri -e "s/^.*GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/g" /mnt/etc/default/grub
sed -ri -e "s/^.*GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=y/g" /mnt/etc/default/grub
arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=$(cat /mnt/etc/hostname)
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg






# microcode packages