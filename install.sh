#!/bin/bash

#####
# Prompts
#####
prompts() {
	while true ; do
	clear

	EFI_INSTALL=0
	ls /sys/firmware/efi/efivars > /dev/null
	[ $? == 0 ] && EFI_INSTALL=1

	SCRIPT_TIMEZONE="Asia/Tokyo"
	read -p "Time zone [$SCRIPT_TIMEZONE]: "
	! [ -z $REPLY ] && SCRIPT_TIMEZONE=$REPLY
	
	SCRIPT_LOCALE=en_US.UTF-8
	read -p "Locale [$SCRIPT_LOCALE]: ";
	! [ -z $REPLY ] && SCRIPT_LOCALE=$REPLY

	SCRIPT_HOSTNAME=arch
	read -p "System hostname [$SCRIPT_HOSTNAME]: ";
	! [ -z $REPLY ] && SCRIPT_HOSTNAME=$REPLY

	SCRIPT_BOOTLOADER_ID=GRUB
	read -p "Identifier in the bootloader [$SCRIPT_BOOTLOADER_ID]: ";
	! [ -z $REPLY ] && SCRIPT_BOOTLOADER_ID=$REPLY

	SCRIPT_GRUB_LANG=en
	read -p "Language in the bootloader [$SCRIPT_GRUB_LANG]: ";
	! [ -z $REPLY ] && SCRIPT_GRUB_LANG=$REPLY

	read -p "Would you like to install os-prober? [y/N]: "
	[ "$REPLY" == "y" ] && SCRIPT_OS_PROBER="os-prober"
	
	SCRIPT_KERNEL="1"
	printf "Which kernel(s) would you like to install?\n1) linux-lts\n2) linux\n3) linux-hardened\n4) linux-zen\n0) without kernel\n"
	read -p "Choose multiple of them, by separating the numbers with a ' ' [$SCRIPT_KERNEL]: ";
	! [ -z $REPLY ] && SCRIPT_KERNEL=$REPLY
	
	SCRIPT_CPU_MITIGATIONS="0"
	printf "Which cpu microcode package would you like to install?\n0) none\n1) amd-ucode\n2) intel-ucode\n"
	read -p "Please choose cpu microcode mitigation to be installed [$SCRIPT_CPU_MITIGATIONS]: ";
	! [ -z $REPLY ] && SCRIPT_CPU_MITIGATIONS=$REPLY

	SCRIPT_ADDITIONAL_PACKAGES=""
	read -p "Additional packages to install []: ";
	! [ -z $REPLY ] && SCRIPT_ADDITIONAL_PACKAGES=$REPLY

	clear
	echo "Timezone: $SCRIPT_TIMEZONE"
	echo "Locale: $SCRIPT_LOCALE"
	echo "Hostname: $SCRIPT_HOSTNAME"
	echo "Bootloader ID: $SCRIPT_BOOTLOADER_ID"
	echo "Grub language: $SCRIPT_GRUB_LANG"
	echo "Chosen kernel(s): $SCRIPT_KERNEL"
	echo "Chosen cpu microcode mitigation: $SCRIPT_CPU_MITIGATIONS"
	echo "Additional packages to install: $SCRIPT_ADDITIONAL_PACKAGES"
	read -p "Are the settings correct? [y/N]: "
	[ $REPLY == "y" ] && break
	done
}

#####
# Bootstrap
#####
bootstrap() {
	timedatectl set-ntp true
	case $SCRIPT_CPU_MITIGATIONS in
		0)
			SCRIPT_CPU_MITIGATIONS="" ;;
		1)
			SCRIPT_CPU_MITIGATIONS="amd-ucode" ;;
		2)
			SCRIPT_CPU_MITIGATIONS="intel-ucode" ;;
	esac

	TEMP=""
	for KERNEL in $SCRIPT_KERNEL ; do
		case $KERNEL in
		1)
			TEMP+=" linux-lts linux-lts-headers" ;;
		2)
			TEMP+=" linux linux-headers" ;;
		3)
			TEMP+=" linux-hardened linux-hardened-headers" ;;
		4)
			TEMP+=" linux-zen linux-zen-headers" ;;
		0)
			TEMP+="" ;;
		esac
	done

	pacstrap /mnt base btrfs-progs cronie efibootmgr dkms grub $TEMP linux-firmware mkinitcpio nano networkmanager sudo $SCRIPT_OS_PROBER $SCRIPT_CPU_MITIGATIONS $SCRIPT_ADDITIONAL_PACKAGES
	genfstab -U /mnt > /mnt/etc/fstab

	echo "Defaults editor=/usr/bin/rnano" >> /mnt/etc/sudoers
	arch-chroot /mnt sed -ri -e "s/^#.*%wheel ALL=\(ALL:ALL\) ALL/%wheel ALL=(ALL:ALL) ALL/g" /etc/sudoers

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
	arch-chroot /mnt cp /usr/share/locale/$SCRIPT_GRUB_LANG\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/$SCRIPT_GRUB_LANG.mo
	arch-chroot /mnt sed -ri -e "s/^HOOKS=.*/HOOKS=\(systemd\ autodetect\ modconf\ block\ keyboard\ sd-vconsole\ sd-encrypt\ fsck\ filesystems\)/g" /etc/mkinitcpio.conf

	arch-chroot /mnt systemctl enable NetworkManager
	arch-chroot /mnt systemctl enable cronie
}

#####
# GRUB configuration
#####
grub_config() {
	arch-chroot /mnt sed -ri -e "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/g" /etc/default/grub
	arch-chroot /mnt sed -ri -e "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=3/g" /etc/default/grub
	arch-chroot /mnt sed -ri -e "s/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/g" /etc/default/grub
	! [ -z $SCRIPT_OS_PROBER ] && arch-chroot /mnt sed -ri -e "s/^.GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/g" /etc/default/grub
}

# bash <(curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/scripts/pacman.sh) auto

read -p "Do you want to run disk setup? [y/N]: "
[ "$REPLY" == "y" ] && bash <(curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/disk-setup.sh)
exit
[ -f "pre-install-hook.sh" ] && bash pre-install-hook.sh &&
prompts
bootstrap
grub_config

[ -f "post-install-hook.sh" ] && bash post-install-hook.sh

arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=$SCRIPT_BOOTLOADER_ID

arch-chroot /mnt

arch-chroot /mnt mkinitcpio -P
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

CHROOT_INSTALL_FILES=("de-gnome" "filesystem-packages" "flatpaks" "pacman" "security-hardening" "test")
for FILE in ${CHROOT_INSTALL_FILES[@]} ; do
	! [ -f "install-$FILE.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/scripts/$FILE.sh > /mnt/root/fulos-$FILE.sh
	[ $? != 0 ] && exit 1
	chmod +x /mnt/root/fulos-$FILE.sh
done
