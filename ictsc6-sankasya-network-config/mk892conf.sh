#! /bin/bash
#2016/08/22 15:25 yabuno

team_number=$1;
team_network_number=`expr $team_number + 100`;
team_vlan_mult100=`expr $team_number \* 100`;
rm conf_temp;

printf "enable
configure terminal

no ip domain-lookup

line con 0
exec-timeout 0 0
no domain-lookup
exit

no cdp run

hostname T%02d-892J

vlan $team_vlan_mult100
vlan `expr $team_vlan_mult100 + 10`
vlan `expr $team_vlan_mult100 + 11`
vlan `expr $team_vlan_mult100 + 12`


interface vlan 2
no shut
exit

interface vlan `expr $team_vlan_mult100 + 10`
no shut
ip add 192.168.101.1 255.255.255.0
exit

interface vlan `expr $team_vlan_mult100 + 11`
no shut
ip add 192.168.102.2 255.255.255.0
exit

interface vlan `expr $team_vlan_mult100 + 12`
no shut
ip add 192.168.103.3 255.255.255.0
exit

interface range fa0-1
description problem
no shut
switchport mode access
switchport access vlan `expr $team_vlan_mult100 + 10`
exit

interface fa2
 no shut
 switchport access vlan $team_vlan_mult100
exit

interface fa3
 no shut
 switchport mode trunk
 switchport trunk allowed vlan remov 3-1001
 switchport trunk allowed vlan remov 1006-4094
 switchport trunk allowed vlan add `expr $team_vlan_mult100 + 10`-`expr $team_vlan_mult100 + 12`
 switchport trunk allowed vlan add $team_vlan_mult100
exit

int ran fa4-5
 description problem
 no shut
 switchport mode access
 switchport access vlan `expr $team_vlan_mult100 + 10`
exit

int fa6
 no shut
 switchport mode access
 switchport access vlan 2
exit

int fa7
 no shut
 switchport trunk native vlan 2
 switchport trunk allowed vlan remov 2-1001
 switchport trunk allowed vlan remov 1006-4094
 switchport trunk allowed vlan add `expr $team_vlan_mult100 + 10`-`expr $team_vlan_mult100 + 12`
 switchport mode trunk
exit

int fa8
 no shut
exit

int fa8.1
 no shut
 encap dot1 2
 ip add 192.168.104.1 255.255.255.0
exit

router ospf 1
redistri rip subnet
network 192.168.101.0 0.0.0.255 area 0
network 192.168.102.0 0.0.0.255 area 0
network 192.168.104.0 0.0.0.255 area 0
network 192.168.105.0 0.0.0.255 area 0
default-information originate
exit

router rip
version 2
! redistri ospf 1
network 192.168.103.0
exit
ip route 0.0.0.0 0.0.0.0 192.168.101.1

##VPN
crypto isakmp policy 1
 encr 3des
 authentication pre-share
crypto isakmp key pkpk address <PEER先アドレス>

crypto ipsec transform-set TEAM%02d-IPSEC esp-3des esp-sha-hmac

crypto map MAP-TEAM%02d 1 ipsec-isakmp
 set peer <PEER先アドレス>
 set transform-set TEAM%02d-IPSEC
 match address 100
exit

access-list 100 permit ip 192.168.103.0 0.0.0.255 <PEER先アドレス> 0.0.0.255

#interface vlan 112
#crypto map MAP-TEAM%02d

write memory
" $1 $1 $1 $1 $1>> conf_temp;
cat conf_temp
Add Comment C