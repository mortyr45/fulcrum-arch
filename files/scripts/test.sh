#!/bin/bash

# Performance
systemctl enable systemd-oomd

# Other
pacman --noconfirm -S zsh cronie openssh man-db man-pages gufw
systemctl enable sshd
systemctl enable cronie
chsh -s /bin/zsh fulcrum
sed -ri -e "s/^.*set\ softwrap.*/set\ softwrap/g" /etc/nanorc

#in /etc/pacman.d/mirrorlist set the desired mirror
#pacman -Syyu
