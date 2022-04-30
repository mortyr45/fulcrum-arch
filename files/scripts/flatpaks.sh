#!/bin/bash

pacman -Q flatpak
if [ $? != 0 ] ; then
    pacman --noconfirm -S flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

pacman -Q fwupd
[ $? != 0 ] && pacman --noconfirm -S fwupd

flatpak install --noninteractive \
com.github.tchx84.Flatseal \
de.haeckerfelix.Shortwave \
dev.geopjr.Collision \
org.gnome.Evince \
org.gnome.gedit \
org.gnome.Calculator \
org.gnome.Calendar \
org.gnome.Characters \
org.gnome.clocks \
org.gnome.FileRoller \
org.gnome.Firmware \
org.gnome.Logs \
org.gnome.gThumb \
org.gnome.gitlab.somas.Apostrophe \
org.gnome.gitlab.somas.Apostrophe.Plugin.TexLive \
org.mozilla.firefox
