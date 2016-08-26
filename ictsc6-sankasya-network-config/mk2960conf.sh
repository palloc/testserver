#! /bin/bash

# 2016/08/22/15:18 yoshikawa

team_number=$1;
team_vlan_num_110=`expr ($team_number \* 100) + 10`;
team_vlan_num_111=`expr ($team_number \* 100) + 11`;
team_vlan_num_112=`expr ($team_number \* 100) + 12`;

rm conf_temp;

printf "enable
configure terminal

no ip domain-lookup

line con 0
exec-timeout 0 0
no domain-lookup
exit

no cdp run

hostname T%02d-2960
vtp mode transparent

no cdp run

vlan 2301
vlan 2302

! NAT-PT(tmp)
vlan 31
int range fa0/2 - 6
desc problem
no shut
switch access vlan 31
exit

int fa0/7
no shut
switchport mode trunk
exit

int fa0/8
 switchport trunk native vlan 2
 switchport trunk allowed vlan remov 2-1001
 switchport trunk allowed vlan remov 1006-4094
 switchport trunk allowed vlan add $team_vlan_num_110,$team_vlan_num_111, $team_vlan_num_112,2301,2302
 switchport mode trunk
exit

! RIP+OSPF(OSPF)
vlan 11
int range fa0/14 - 18
desc problem
no shut
switch access vlan 11
exit

! prevent VLAN loop
vlan 2
int fa0/13
switchport access vlan 2
switchport mode access
no shut
exit

int fa0/19
switchport access vlan 2
switchport mode access
no shut
exit

! vlan missMatch
vlan 100
int range fa0/20 - 24
desc problem
no shut
switch access vlan 100
exit

### happen problem ###
interface fa0/20
no switchport access vlan 100
exit

vlan 2302
 remote
exit

monitor session 1 source remote vlan 2302
monitor session 1 destination interface fastEthernet 0/1

write memory
" $1 >> conf_temp;
cat conf_temp

