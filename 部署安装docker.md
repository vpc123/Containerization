### Ubuntu中安装配置Docker的apt源

不完全适用：2018/12/11已经废弃了下面这种安装方式。

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
