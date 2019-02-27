#!/bin/bash
# 等待所有pod启动完毕后，直接执行以下命令。
v=""
for i in `kubectl get po -n kube-system -o wide | awk '{print $6}' | grep -v IP`; do v="$v $i:6379";done
kubectl exec -ti redis-cluster-ss-5 -n kube-system -- redis-trib.rb create --replicas 1 $v
#执行检查pod信息
kubectl exec -ti redis-cluster-ss-0 -n kube-system -- redis-cli -a 123456 cluster nodes
