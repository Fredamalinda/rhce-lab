#!/bin/bash

echo "Install Python3.9"
ansible all -b -m raw -a "sudo dnf install -y python3.9"

echo "Creating User Automation"
ansible all -b -m user -a "name=automation password=$PW shell=/bin/bash groups=wheel"

echo "Deploying SSH Key for automation user"
ansible all -b -m authorized_key -a "user=automation state=present key='$PK'"

echo "Configuring Passworless Sudo"
ansible all -b -m copy -a "content='automation ALL=(ALL) NOPASSWD: ALL' dest=/etc/sudoers.d/automation mode=0440 validate='visudo -cf %s'"

echo "Setup Complete"
