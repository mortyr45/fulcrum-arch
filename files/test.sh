#!/bin/bash

# Other
pacman --noconfirm -S auto-cpufreq ufw gnome-shell-extension-installer gufw openssh zsh
systemctl enable sshd.service
chsh -s /bin/zsh fulcrum
sed -ri -e "s/^.*set\ softwrap.*/set\ softwrap/g" /etc/nanorc

#in /etc/pacman.d/mirrorlist set the desired mirror
#pacman -Syyu
