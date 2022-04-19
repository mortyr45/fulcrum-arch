#!/bin/bash

# Other
pacman --noconfirm -S zsh openssh man-db man-pages gufw
systemctl enable sshd
chsh -s /bin/zsh fulcrum
sed -ri -e "s/^.*set\ softwrap.*/set\ softwrap/g" /etc/nanorc

#in /etc/pacman.d/mirrorlist set the desired mirror
#pacman -Syyu
