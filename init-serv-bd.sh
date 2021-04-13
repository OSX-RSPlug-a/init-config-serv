#!/bin/bash

if [[ "${UID}" -ne 0 ]]
then
 echo 'Must execute with sudo or root' >&2
 exit 1
fi

# Ensure system is up to date
sudo apt update -y

# Upgrade the system
sudo apt upgrade -y


# Disabling root login 
echo "PermitRootLogin no" >> /etc/ssh/sshd_config 

sudo iptables -F
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT	
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 5432 -j ACCEPT
sudo iptables -P INPUT DROP
sudo netfilter-persistent save
sudo netfilter-persistent reload



# Fail2Ban install 
sudo apt install fail2ban -y
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

echo "
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 4
" >> /etc/fail2ban/jail.local


# Install essential packs
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

sudo apt-get update

sudo apt-get install postgresql-13 libpq-dev postgresql-server-dev-13 net-tools -y


# Cleanup
sudo apt autoremove
sudo apt clean 


exit 0
