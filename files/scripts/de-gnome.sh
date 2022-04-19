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
    power-profiles-daemon
}

printf "1) Regular GNOME desktop install\n2) GNOME desktop with extras package\n3) Bare GNOME desktop install\n"
read -p "Choose installation type [1]: "

case $REPLY in
    1)
        pacman --noconfirm -S gnome
        ;;
    2)
        pacman --noconfirm -S gnome gnome-extras
        ;;
    3)
        gnome_bare
        ;;
    *)
        pacman --noconfirm -S gnome
        ;;
esac

systemctl enable gdm
