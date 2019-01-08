
    $curl -sSL https://get.daocloud.io/docker-experimental | sh
    
    $curl -sSL https://get.daocloud.io/docker-test | sh

link:http://get.daocloud.io/#install-docker


##### 二进制推进部署方式：

https://download.docker.com/linux/static/stable/aarch64/


二、二进制安装 Docker CE 
    （1）下载静态二进制存档。转到 https://download.docker.com/linux/static/stable/ （或更改stable为edge或test），选择您的硬件平台，然后下载.tgz与您要安装的Docker CE版本相关的文件。 
    （2）获取二进制文件并解压；
    
    $wget https://download.docker.com/linux/static/stable/x86_64/docker-18.06.0-ce.tgz 
    $tar -xvf docker-18.06.0-ce.tgz 
    $sudo cd /usr/local/bin  #对于docker的所有操作都要在该目录下
    $sudo ./dockerd &#启动docker 
    
    配置docker的工作路径
    
    $export DOCKER_HOME=/usr/local/bin
    $export PATH=.:$DOCKER_HOME:$PATH
    
    刷新 /etc/profile
    
    $source /etc/profile
