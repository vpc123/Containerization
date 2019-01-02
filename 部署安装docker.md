### Ubuntu中安装配置Docker的apt源

不完全适用：2018/12/11已经废弃了下面这种安装方式。

###### 特别强调：一定要注意时间同步尤其自己的虚机操作的时候。

同步网络时间操作：

    $date  查看当前系统时间
    $yum install -y ntpdate 安装ntpdate程序
    $ntpdate time.windows.com  从互联网更新系统时间
    $ntpdate cn.pool.ntp.org   从互联网更新系统时间
    $date  再次查看当前系统时间


1. 安装包，允许 apt 命令 HTTPS 访问 Docker 源。

    $ sudo apt-get install \
    
    apt-transport-https \
    
    ca-certificates \
    
    curl \
    
    software-properties-common


2. 添加 Docker 官方的 GPG


    $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

3. 将 Docker 的源添加到 /etc/apt/sources.list

    $ sudo add-apt-repository \
    
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    
      $(lsb_release -cs) \
    
      stable"

安装 Docker

    $sudo apt-get update
    $sudo apt-get install docker-ce


### 标准安装方式


    $apt-get install -y docker.io
	$systemctl enable docker
	$systemctl start docker



### Centos7中安装配置Docker的yum源

#### 安装Docker

###### 特别强调：一定要注意时间同步尤其自己的虚机操作的时候。

同步网络时间操作：

    $date  查看当前系统时间
    $yum install -y ntpdate 安装ntpdate程序
    $ntpdate time.windows.com  从互联网更新系统时间
    $ntpdate cn.pool.ntp.org   从互联网更新系统时间
    $date  再次查看当前系统时间


Kubernetes从1.6开始使用CRI(Container Runtime Interface)容器运行时接口。默认的容器运行时仍然是Docker，使用的是kubelet中内置dockershim CRI实现。

安装docker的yum源:

    $yum install -y yum-utils device-mapper-persistent-data lvm2
    $yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo


查看最新的Docker版本：

    $yum list docker-ce.x86_64  --showduplicates |sort -r
    docker-ce.x86_643:18.09.0-3.el7 docker-ce-stable
    docker-ce.x86_6418.06.1.ce-3.el7docker-ce-stable
    docker-ce.x86_6418.06.0.ce-3.el7docker-ce-stable
    docker-ce.x86_6418.03.1.ce-1.el7.centos docker-ce-stable
    docker-ce.x86_6418.03.0.ce-1.el7.centos docker-ce-stable
    docker-ce.x86_6417.12.1.ce-1.el7.centos docker-ce-stable
    docker-ce.x86_6417.12.0.ce-1.el7.centos docker-ce-stable


Kubernetes 1.12已经针对Docker的1.11.1, 1.12.1, 1.13.1, 17.03, 17.06, 17.09, 18.06等版本做了验证，需要注意Kubernetes 1.12最低支持的Docker版本是1.11.1。Kubernetes 1.13对Docker的版本依赖方面没有变化。 我们这里在各节点安装docker的18.06.1版本

    $yum makecache fast
    
    $yum install -y --setopt=obsoletes=0 \
      docker-ce-18.06.1.ce-3.el7
    
    $systemctl start docker
    $systemctl enable docker


确认一下iptables filter表中FOWARD链的默认策略(pllicy)为ACCEPT。

    $iptables -nvL
    Chain INPUT (policy ACCEPT 263 packets, 19209 bytes)
     pkts bytes target prot opt in out source   destination
    
    Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
     pkts bytes target prot opt in out source   destination
    0 0 DOCKER-USER  all  --  *  *   0.0.0.0/00.0.0.0/0
    0 0 DOCKER-ISOLATION-STAGE-1  all  --  *  *   0.0.0.0/00.0.0.0/0
    0 0 ACCEPT all  --  *  docker0  0.0.0.0/00.0.0.0/0ctstate RELATED,ESTABLISHED
    0 0 DOCKER all  --  *  docker0  0.0.0.0/00.0.0.0/0
    0 0 ACCEPT all  --  docker0 !docker0  0.0.0.0/00.0.0.0/0
    0 0 ACCEPT all  --  docker0 docker0  0.0.0.0/00.0.0.0/0


Docker从1.13版本开始调整了默认的防火墙规则，禁用了iptables filter表中FOWARD链，这样会引起Kubernetes集群中跨Node的Pod无法通信。但这里通过安装docker 1806，发现默认策略又改回了ACCEPT，这个不知道是从哪个版本改回的，因为我们线上版本使用的1706还是需要手动调整这个策略的。