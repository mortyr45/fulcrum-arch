#!/bin/bash

# Security
echo "Defaults editor=/usr/bin/rnano" >> /etc/sudoers
passwd --lock root

pacman -S ufw
systemctl disable iptables
systemctl enable ufw
ufw default deny incoming
ufw default deny forward
ufw default allow outgoing
ufw allow from 192.168.0.0/23
ufw limit 22/tcp

# Packages

