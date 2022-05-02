#!/bin/bash

pacman --noconfirm -Sy ufw
systemctl disable --now iptables.service
systemctl enable --now ufw.service
