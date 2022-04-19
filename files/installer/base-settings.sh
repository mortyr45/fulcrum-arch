#!/bin/bash

echo "Defaults editor=/usr/bin/rnano" >> /mnt/etc/sudoers
arch-chroot /mnt sed -ri -e "s/^#.*%wheel ALL=\(ALL:ALL\) ALL/%wheel ALL=(ALL:ALL) ALL/g" /etc/sudoers
arch-chroot /mnt passwd --lock root

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
arch-chroot /mnt sed -ri -e "s/^#$SCRIPT_LOCALE/$SCRIPT_LOCALE/g" /etc/locale.gen
arch-chroot /mnt locale-gen
echo "$SCRIPT_HOSTNAME" > /mnt/etc/hostname
arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=$SCRIPT_BOOTLOADER_ID
arch-chroot /mnt cp /usr/share/locale/$SCRIPT_GRUB_LANG\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/$SCRIPT_GRUB_LANG.mo

arch-chroot /mnt pacman --noconfirm -S networkmanager
arch-chroot /mnt systemctl enable NetworkManager
