#! /bin/bash
# 2016/08/22 15:11 kado
team_number=$1;
team_network_number110=`expr ($team_number \* 100) + 10`;
team_network_number111=`expr ($team_number \* 100) + 11`;
team_network_number112=`expr ($team_number \* 100) + 12`;
rm conf_temp;

printf "enable
configure terminal

line con 0
exec-timeout 0 0
no domain-lookup
exit


no cdp run

hostname T%02d-1941

router ospf 1
network 192.168.106.0 0.0.0.255 area 0
exit

ipv6 unicast-routing
int gi0/1
no shut
ipv6 enable
ipv6 address $1::1/64
ipv6 nd ns 30000
exit

int serial0/0/0
no shut
ip address 192.168.106.2 255.255.255.0
encapsulation ppp
exit

ip domain name 1941-$1a.ictsc6.pkpk

#password
service password-encryption
enable secret dEB5ZkAhZjNz

ip ssh version 2

write memory

" $1 >> conf_temp;
cat conf_temp
