#!/bin/bash

read -p "Script to run: "
bash <(curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/$REPLY.sh)
