#! /bin/bash
# 2016/08/22 15:11 kado
team_number=$1;
team_network_number110=`expr ($team_number \* 100) + 10`;
team_network_number111=`expr ($team_number \* 100) + 11`;
team_network_number112=`expr ($team_number \* 100) + 12`;
rm conf_temp;

printf "enable
configure terminal

service password-encryption
enable secret bnVld0Ah
username ictsc6 password k1d0_deN6cst


line con 0
login local
exec-timeout 0 0
no ip domain-lookup

line vty 0 4
transport input ssh
login local


snmp-server community ictsc6 RO
snmp-server host <運営ライフサーバー> ictsc6

no cdp run

interface fa0/0
no shutdown
ip address 192.168.104.2 255.255.255.0
exit

interface fa0/1
no shutdown
ip address 192.168.107.1 255.255.255.0
exit

int serial0/0/0
shut
ip address 192.168.106.1 255.255.255.0
clock rate 64000
bandwidth 64
encapsulation hdlc
ip access-group 100 in
exit

router ospf 1
network 192.168.104.0 0.0.0.255 area 0
network 192.168.106.0 0.0.0.255 area 0
network 192.168.107.0 0.0.0.255 area 0
exit

access-list 100 permit tcp host 192.168.106.2 any eq 22

ip domain name 1841-$1c.ictsc6.pkpk
crypto key generate rsa
2048
yes

ip ssh version 2


write memory
hostname SFTUSB

" $1 >> conf_temp;
cat conf_temp
