#!/bin/bash
#ip网段设置 
# 定义两个标签名输入参数，添加修改
#标签1  custom:nodeName  标签2 kubernets.io/hostname：name
# $bash  up-nodes.sh nodeName(下线节点名称)  nodeNetWork(自定义网段信息)
nodeName=$1;      			        #机器名
nodeNetWork=$2;    				   	#自定义网段
nodeSelectLable=nodeName;           #标签
nowtime=`date --date='0 days ago' "+%Y-%m-%dT%H:%M:%S"`

#第一步：编辑ippool.yaml

var1=`echo $nodeNetWork|awk -F '/' '{print $2}'`
var2="blockSize: "$var1
ipPoolName="name: "$nodeName
ipPoolLabel="nodeSelector: kubernetes.io/hostname!="$nodeName

# sed -i "s/creationTimestamp:.*/creationTimestamp: $nowtime/g" ippool.yaml
sed -i "s/name:.*/$ipPoolName/g" ippool.yaml
sed -i "s/blockSize:.*/$var2/g" ippool.yaml
sed -i "s#cidr:.*#cidr: $nodeNetWork#g" ippool.yaml
sed -i 's#nodeSelector:.*#'"$ipPoolLabel#g"'' ippool.yaml
calicoctl create -f ippool.yaml
#第二步：新的测试版本进行追加逻辑实现
calicoctl get ippool  default-ipv4-ippool  -oyaml  >> default-ipv4.yaml
rep=$(sed  -n "/nodeSelector/p" default-ipv4.yaml)
ipNetWork=$rep" \&\& kubernetes.io\/hostname!="$nodeName

ipLine=$(grep -n "nodeSelector:" default-ipv4.yaml | awk -F ':' '{print $1}')

sed -i  '/nodeSelector:/{s/$/'"$ipNetWork"'/}' default-ipv4.yaml 

# 老版本中判断是否追加代码逻辑
# if [ -z "$rep" ];then 
#     echo "STRING is empty" 
#     sed -i "s/creationTimestamp:.*/creationTimestamp: $nowtime/g" default-ipv4.yaml
#     sed -i '$a\  '"$ipNetWork"'' default-ipv4.yaml
# else
#     echo "not empty!"
#     # sed -i  "s#nodeSelector:.*#$ipNetWork#g" default-ipv4.yaml
#     sed -i "s/creationTimestamp:.*/creationTimestamp: $nowtime/g" default-ipv4.yaml
#     sed -i 's#nodeSelector:.*#'"$ipNetWork"'#g' default-ipv4.yaml
#     echo $rep
# fi

calicoctl delete ippool  default-ipv4-ippool
calicoctl create -f   default-ipv4.yaml

# calicoctl edit nodeName  node  