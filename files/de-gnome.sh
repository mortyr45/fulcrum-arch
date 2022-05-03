#!/bin/bash

gnome_bare() {
	pacman --noconfirm -S \
	alacritty \
	ffmpeg \
	gdm \
	gnome-backgrounds \
	gnome-color-manager \
	gnome-control-center \
	gnome-disk-utility \
	gnome-keyring \
	gnome-screenshot \
	gnome-session \
	gnome-settings-daemon \
	gnome-shell \
	gnome-shell-extensions \
	gnome-tweaks \
	grilo-plugins \
	gvfs \
	gvfs-afc \
	gvfs-goa \
	gvfs-google \
	gvfs-gphoto2 \
	gvfs-mtp \
	gvfs-nfs \
	gvfs-smb \
	jack2 \
	libnautilus-extension \
	libva \
	mutter \
	nautilus \
	noto-fonts \
	noto-fonts-emoji \
	pipewire-media-session \
	xdg-user-dirs-gtk
}

GNOME_INSTALLATION_TYPE="1"
printf "1) Regular GNOME desktop install\n2) GNOME desktop with extras package\n3) Bare GNOME desktop install\n"
read -p "Choose installation type [$GNOME_INSTALLATION_TYPE]: "
! [ -z $REPLY ] && GNOME_INSTALLATION_TYPE=$REPLY

case $GNOME_INSTALLATION_TYPE in
	1)
		pacman --noconfirm -S gnome ;;
	2)
		pacman --noconfirm -S gnome gnome-extras ;;
	3)
		gnome_bare ;;
esac

systemctl enable gdm.service
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
