### 搭建redis集群模式



作者：流火夏梦          

时间：2019/2/27

地点：中移在线-实习


涉及主机：
19测试集群    192.168.26.xx

操作步骤：（非常详细）如需要备份，则加上备份说明 
1 创建挂载文件,文件在部署目录下方(创建完成redis-client的configmap)

```
$kubectl -n kube-system create cm redis-client --from-file=./client.rb
```

2 启动redis集群信息

```
$kubectl apply -f ./
```

3 等待所有pod运行起来以后,运行分区执行脚本

```
$bash slot-start.sh
```



##### 检查步骤：

查看集群node信息

```
$kubectl exec -ti redis-cluster-ss-0 -n public-service -- redis-cli -a 123456   cluster nodes
```

查看集群信息

```
$kubectl exec -ti redis-cluster-ss-0 -n public-service -- redis-cli -a 123456   cluster info
```

#### 总结

关于redis的部署涉及到密码登录验证信息，整个流程大致一周时间针对redis的部署搭建完全投入商业使用。从开始挂载配置信息挂载Pv存储等，后来开始完全摆脱pv验证存储通过configmap进行系统设置。
