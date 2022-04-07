#!/bin/bash

SCRIPT_TIMEZONE=

ln -sf /usr/share/zoneinfo/$SCRIPT_TIMEZONE /etc/localtime
locale-gen
