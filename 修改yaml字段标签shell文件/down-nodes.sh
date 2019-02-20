#!/bin/bash
# 修改下线脚本文件
calicoctl get ippool  default-ipv4-ippool  -oyaml  >> default-ipv4-down.yaml
sed -i 's#nodeSelector: kubernets.io/hostname==#nodeSelector: kubernets.io/hostname!=#g'  default-ipv4-down.yaml
calicoctl delete ippool  default-ipv4-ippool
calicoctl create -f   default-ipv4-down.yaml
