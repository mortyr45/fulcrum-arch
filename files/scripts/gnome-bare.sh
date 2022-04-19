#!/bin/bash

pacman --noconfirm -S \
alacritty \
ffmpeg \
gdm \
gnome-backgrounds \
gnome-color-manager \
gnome-control-center \
gnome-disk-utility \
gnome-extensions \
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

systemctl enable gdm
