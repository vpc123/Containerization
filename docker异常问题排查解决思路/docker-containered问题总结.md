### docker出现新建的pod无法再某个节点新建pod

1 问题原因是/var/run/docker/libcontainerd无法启动新的docker容器问题。

### docker  containerd正常运行的现象是执行命令

    $systemctl status docker 

可以观测到一行info信息为：

    docker-containerd  -l  unix:///var/run/docker/libcontainerd.sock --metrics-interval=0 --start-timeout 2m  --*

则正常。


### 解决办法

1  暂时解决办法：

    #k8s集群将次node调度为不可调度
	$kubectl cordon  node名

2  最终解决办法：

	$systemctl daemon-reload
	$systemctl restart docker
