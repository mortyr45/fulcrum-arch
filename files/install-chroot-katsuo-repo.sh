#!/bin/bash

echo "[katsuo]" >> /etc/pacman.conf
echo "Server = https://pacman.katsuo.fish/core/$arch" >> /etc/pacman.conf
echo "SigLevel = PackageRequired" >> /etc/pacman.conf
