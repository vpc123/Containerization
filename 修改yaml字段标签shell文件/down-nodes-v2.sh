#!/bin/bash
# 修改下线脚本文件
# 执行命令脚本如下:
# $bash down-nodes.sh nodeName(下线节点名称)
nodeName=$1;  
calicoctl get ippool  default-ipv4-ippool  -oyaml  >> default-ipv4-down.yaml
ippoolNodeName=" \&\& "

sed -i '/=yes/d' example.txt
# sed -i 's#nodeSelector: kubernets.io/hostname==#nodeSelector: kubernets.io/hostname!=#g'  default-ipv4-down.yaml
calicoctl delete ippool  default-ipv4-ippool
calicoctl delete ippool  $nodeName
calicoctl create -f  default-ipv4-ippool.yaml

