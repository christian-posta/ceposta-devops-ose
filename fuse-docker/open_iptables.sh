#!/bin/sh
sudo iptables -A INPUT -p tcp --dport 8101 -j ACCEPT -m comment --comment 'fuse ssh console'
sudo iptables -A INPUT -p tcp --dport 2181 -j ACCEPT -m comment --comment 'ZK server port'
sudo iptables -A INPUT -p tcp --dport 2888 -j ACCEPT -m comment --comment 'ZK peer port'
sudo iptables -A INPUT -p tcp --dport 3888 -j ACCEPT -m comment --comment 'ZK election port'
sudo iptables -A INPUT -p tcp --dport 44444 -j ACCEPT -m comment --comment 'RMI server port'
sudo iptables -A INPUT -p tcp --dport 1099 -j ACCEPT -m comment --comment 'RMI Registry port'
sudo iptables -A INPUT -p tcp --dport 8181 -j ACCEPT -m comment --comment 'fuse http port'
sudo iptables -A INPUT -p tcp --dport 8443 -j ACCEPT -m comment --comment 'fuse https port'
sudo service iptables save
sudo service iptables restart