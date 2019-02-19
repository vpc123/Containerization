#!/bin/bash
#ip网段设置 
# 定义两个标签名输入参数，添加修改
#标签1  custom:nodeName  标签2 kubernets.io/hostname：name
var nodeName=$0;      			        #机器名
var nodeNetWork=$1;    				   	#自定义网段
var nodeSelectLable=nodeName;           #标签

#第一步：编辑nodeName.yaml
calicoctl get nodeName  node  -oyaml  >> nodeName.yaml
sed -i "/name: /i\  label:" nodeName.yaml
sed -i "/name: /i\    custom: $nodeName" nodeName.yaml
sed -i "/name: /i\    kubernets.io/hostname: $nodeName" nodeName.yaml

#第一步：编辑ippool.yaml
var1=`echo $nodeNetWork|awk -F '/' '{print $2}'`
sed -i 's/blockSize:.* /blockSize: $var1/g' ippool.yaml
sed -i 's/cidr:.* /cidr: $nodeNetWork/g' ippool.yaml
sed -i 's/nodeSelector:.*/nodeSelector: custom==$nodeName/g' ippool.yaml

#第三步：
calicoctl get ippool  default-ipv4-ippool  -oyaml  >> default-ipv4.yaml

rep=$(sed  -n "/nodeSelector/p" default-ipv4.yaml)

if [ -z "$rep" ];then 
    echo "STRING is empty" 
    sed -i "/natOutgoing: /a\  nodeSelector: kubernets.io/hostname!=$nodeName" default-ipv4.yaml
else
    echo "not empty!"
    sed -i 's/nodeSelector:.*/nodeSelector: kubernets.io/hostname!=$nodeName/g' default-ipv4.yaml
    echo $rep
fi

# calicoctl edit nodeName  node  