#!/bin/bash

# Root account
passwd --lock root

# Firewall
pacman --noconfirm -S ufw
systemctl disable iptables
ufw default deny incoming
ufw default deny forward
ufw default allow outgoing
sudo ufw allow from 203.0.113.0/24 proto tcp to any port 22
systemctl enable ufw
ufw enable

pacman -Q openssh
if [ $? == 0 ] ; then
    sed -ri -e "s/^.*PermitRootLogin.*/PermitRootLogin\ no/g" /etc/ssh/sshd_config
    sed -ri -e "s/^.*MaxAuthTries.*/MaxAuthTries\n 3/g" /etc/ssh/sshd_config
    sed -ri -e "s/^.*PasswordAuthentication.*/PasswordAuthentication\ no/g" /etc/ssh/sshd_config
fi