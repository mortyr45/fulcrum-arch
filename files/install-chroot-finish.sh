#!/bin/bash

mkinitcpio -P
grub-mkconfig -o /boot/grub/grub.cfg
