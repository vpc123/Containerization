## Java项目云平台迁移还有CI/CD构建流程及注意事项


### 1  将jar或者war包制作完成放在容器指定目录中。


### 2  DockerFile中执行相应的启动命令即可。


注意事项：	

1 启动jar的命令为：

    $java  -jar   jar包路径

2 如果出现java应用只可以本地调试不可以外网访问


    $java -Dserver.address=0.0.0.0  -jar   jar包路径

注：这样就可以将容器内部的服务放出来。
