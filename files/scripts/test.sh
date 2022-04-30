#!/bin/bash

# Other
pacman --noconfirm -S auto-cpufreq ufw gnome-shell-extension-installer gufw grub-btrfs openssh timeshift timeshift-autosnap zsh
systemctl enable sshd
timeshift --list
systemctl enable grub-btrfs.path
chsh -s /bin/zsh fulcrum
sed -ri -e "s/^.*set\ softwrap.*/set\ softwrap/g" /etc/nanorc
sed -ri -e "s/^updateGrub=true.*/updateGrub=false/g" /etc/timeshift-autosnap.conf

#in /etc/pacman.d/mirrorlist set the desired mirror
#pacman -Syyu
