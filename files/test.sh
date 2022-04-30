#!/bin/bash

# Other
pacman --noconfirm -S ufw gufw openssh zsh
systemctl enable sshd.service
chsh -s /bin/zsh fulcrum
sed -ri -e "s/^.*set\ softwrap.*/set\ softwrap/g" /etc/nanorc

#in /etc/pacman.d/mirrorlist set the desired mirror
#pacman -Syyu

pacman -Q flatpak
if [ $? != 0 ] ; then
    pacman --noconfirm -S flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

pacman -Q fwupd
[ $? != 0 ] && pacman --noconfirm -S fwupd
