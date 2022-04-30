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

	SCRIPT_TIMEZONE="Etc/UTC"
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
	printf "Which kernel(s) would you like to install?\n1) linux-lts\n2) linux\n3) linux-hardened\n4) linux-zen\n[kernel package name]) custom kernel\n0) without kernel\n"
	read -p "Choose multiple of them, by separating the numbers with a ' ' [$SCRIPT_KERNEL]: ";
	! [ -z $REPLY ] && SCRIPT_KERNEL=$REPLY
	
	SCRIPT_CPU_MITIGATIONS="0"
	printf "Which cpu microcode package would you like to install?\n0) none\n1) amd-ucode\n2) intel-ucode\n3) both\n"
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
	INSTALL_PACKAGES="base btrfs-progs cronie efibootmgr dkms grub linux-firmware mkinitcpio nano networkmanager sudo which"

	timedatectl set-ntp true
	case $SCRIPT_CPU_MITIGATIONS in
		1)
			INSTALL_PACKAGES+=" amd-ucode" ;;
		2)
			INSTALL_PACKAGES+=" intel-ucode" ;;
		3)
			INSTALL_PACKAGES+=" amd-ucode intel-ucode" ;;
		0)
			INSTALL_PACKAGES+="" ;;
	esac

	for KERNEL in $SCRIPT_KERNEL ; do
		case $KERNEL in
		1)
			INSTALL_PACKAGES+=" linux-lts linux-lts-headers" ;;
		2)
			INSTALL_PACKAGES+=" linux linux-headers" ;;
		3)
			INSTALL_PACKAGES+=" linux-hardened linux-hardened-headers" ;;
		4)
			INSTALL_PACKAGES+=" linux-zen linux-zen-headers" ;;
		0)
			INSTALL_PACKAGES+="" ;;
		esac
	done

	INSTALL_PACKAGES+=$SCRIPT_OS_PROBER
	INSTALL_PACKAGES+=" $SCRIPT_ADDITIONAL_PACKAGES"

	pacstrap /mnt $INSTALL_PACKAGES
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

	arch-chroot /mnt hostnamectl hostname $SCRIPT_HOSTNAME
	arch-chroot /mnt timedatectl set-timezone $SCRIPT_TIMEZONE
	arch-chroot /mnt sed -ri -e "s/^#$SCRIPT_LOCALE/$SCRIPT_LOCALE/g" /etc/locale.gen
	arch-chroot /mnt locale-gen
	arch-chroot /mnt localectl set-locale en_US.UTF-8
	arch-chroot /mnt localectl set-keymap us-acentos
	arch-chroot /mnt sed -ri -e "s/^HOOKS=.*/HOOKS=\(systemd\ keyboard\ modconf\ block\ sd-encrypt\ fsck\ filesystems\)/g" /etc/mkinitcpio.conf
	echo "COMPRESSION=\"cat\"" >> /mnt/etc/mkinitcpio.conf

	arch-chroot /mnt systemctl enable NetworkManager.service
	arch-chroot /mnt systemctl enable cronie.service
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

read -p "Do you want to run disk setup? [y/N]: "
[ "$REPLY" == "y" ] && bash <(curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/disk-setup.sh)

[ -f "pre-install-hook.sh" ] && bash pre-install-hook.sh

bash <(curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/pacman.sh) 3
prompts
bootstrap
grub_config

[ -f "post-install-hook.sh" ] && bash post-install-hook.sh

arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=$SCRIPT_BOOTLOADER_ID

arch-chroot /mnt

arch-chroot /mnt mkinitcpio -P
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

CHROOT_INSTALL_FILES=("de-gnome" "filesystem-packages" "pacman" "security-hardening" "test" "timeshift")
for FILE in ${CHROOT_INSTALL_FILES[@]} ; do
	! [ -f "install-$FILE.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/$FILE.sh > /mnt/root/fulos-$FILE.sh
	[ $? != 0 ] && exit 1
	chmod +x /mnt/root/fulos-$FILE.sh
done
