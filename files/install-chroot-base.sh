#!/bin/bash

SCRIPT_TIMEZONE=
SCRIPT_LOCALE=
SCRIPT_HOSTNAME=
SCRIPT_BOOTLOADER_ID=
SCRIPT_GRUB_LANG=

ln -sf /usr/share/zoneinfo/$SCRIPT_TIMEZONE /etc/localtime
sed -ri -e "s!^#$SCRIPT_LOCALE!$SCRIPT_LOCALE!g" /etc/locale.gen
locale-gen
echo "$SCRIPT_HOSTNAME" > /etc/hostname
grub-install --target=x86_64-efi --bootloader-id=$SCRIPT_BOOTLOADER_ID
cp /usr/share/locale/$SCRIPT_GRUB_LANG\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/$SCRIPT_GRUB_LANG.mo

mkinitcpio -P
grub-mkconfig -o /boot/grub/grub.cfg
