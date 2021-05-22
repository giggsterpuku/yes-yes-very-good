#!/bin/bash

### User Auditing ###
# Removes unauthorized users
for i in $(cat /etc/passwd | cut -d ':' -f1);
do
	if !(grep $i admin || grep $i users || grep $i sysusers);
	then
		sudo deluser $i
	fi
done

# Adds users specified in README
for i in $(cat admin && cat users);
do
        if ! grep $i /etc/passwd;
	then
		sudo adduser $i
	fi
done

# Removes users from sudo group
for i in $(getent group sudo | cut -d ':' -f4 | tr ',' " ");
do
        if ! grep $i admin;
        then
                sudo gpasswd -d $i sudo
        fi
done

# Adds admin to sudo group if not yet in it
for i in $(cat admin);
do
	if ! grep sudo /etc/group | grep $i;
	then
                sudo gpasswd -a $i sudo
	fi
done

# Changes passwords of all users (not system)
for i in $(cat admin && cat users);
do
	echo $i':CyberPatriot123!@#$' | sudo chpasswd
done
echo root':CyberPatriot123!@#$' | sudo chpasswd

sudo delgroup nopasswdlogin

# Install PAM modules
sudo apt-get install libpam-cracklib -y

# Removing potentially hazardous packages
for i in $(cat packagelist);
do
	sudo apt-get purge $i -y
done

# Disabling unnecessary services
sudo systemctl disable cups
sudo systemctl disable avahi-daemon
sudo systemctl mask udisks2
sudo systemctl mask ctrl-alt-del.target

# Backdoor Hunting
cat /var/spool/cron/crontabs/*
cat /etc/crontab /etc/anacrontab
cat /etc/sudoers /etc/sudoers.d/*

# Secure permissions
sudo chmod 640 /etc/shadow
sudo chmod 644 /etc/passwd
sudo chmod 644 /etc/group

# File Hunting
find / -name *.mp3
find / -name *.mp4

# General networking kernel settings
sudo wget -O /etc/sysctl.conf https://klaver.it/linux/sysctl.conf
sudo sysctl -p

# Install firewall if not installed
sudo apt install ufw

# Reset firewall rules
sudo ufw reset

# Turn on firewall
sudo ufw enable

# Make general firewall rules
sudo ufw default allow outgoing
sudo ufw default deny incoming

# Update
sudo apt-get update
sudo apt-get dist-upgrade -y
