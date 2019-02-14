# service mesh 开源实现 istio安装测试

### 简介

`istio`是一个`service mesh`开源实现，由Google/IBM/Lyft共同开发。与之类似的还有`conduit`，但是功能不如`istio`丰富稳定。架构图如下：

![5c650f911fcaa](https://i.loli.net/2019/02/14/5c650f911fcaa.png)

![5c650f735125f](https://i.loli.net/2019/02/14/5c650f735125f.png)



`\# 去下面的地址下载压缩包`

`\# https://github.com/istio/istio/releases`

`wget https://github.com/istio/istio/releases/download/0.7.1/istio-0.7.1-linux.tar.gz`

`tar xf istio-0.7.1-linux.tar.gz`

`\# 使用官方的安装脚本安装`

`curl -L https://git.io/getLatestIstio | sh -`

`\# 安装配置环境变量`

`mv istio-0.7.1 /usr/local/`

`ln -sv /usr/local/istio-0.7.1 /usr/local/istio`

`echo 'export PATH=/usr/local/istio/bin:$PATH' > /etc/profile.d/istio.sh`

`source /etc/profile.d/istio.sh`

`istioctl version`

`\# 如果环境不是云环境，不支持LoadBalancer`

`\# 作如下修改，使得 ingress 监听在80和443端口`

`\# 修改 Istio ingress 使用 NodePort`

`\# 修改使用主机端口映射`

`\# 使用此修改版本之后，每台机器只能运行单个实例`

`\# 大概在1548-1590行左右`

`cd /usr/local/istio`

`cp install/kubernetes/istio.yaml install/kubernetes/istio.yaml.ori`

`vim install/kubernetes/istio.yaml`

`...`

`################################`

`\# Istio ingress`

`################################`

`apiVersion: v1`

`kind: Service`

`metadata:`

`name: istio-ingress`

`namespace: istio-system`

`labels:`

`istio: ingress`

`spec:`

`#type: LoadBalancer`

`\# 使用NodePort方式`

`type: NodePort`

`ports:`

`\- port: 80`

`\# nodePort: 32000`

`name: http`

`\- port: 443`

`name: https`

`selector:`

`istio: ingress`

`\-\-\-`

`apiVersion: extensions/v1beta1`

`#kind: Deployment`

`\# 使用DaemonSet部署方式`

`kind: DaemonSet`

`metadata:`

`name: istio-ingress`

`namespace: istio-system`

`spec:`

`#DaemonSet不支持replicas`

`#replicas: 1`

`template:`

`...`

`imagePullPolicy: IfNotPresent`

`ports:`

`\- containerPort: 80`

`#主机80端口映射`

`hostPort: 80`

`\- containerPort: 443`

`#主机443端口映射`

`hostPort: 443`

`...`

`\# 以下两种选择一种安装方式`

`\# 安装不使用认证（不使用tls）`

`kubectl apply -f install/kubernetes/istio.yaml`

`\# 安装使用认证（使用tls）`

`kubectl apply -f install/kubernetes/istio-auth.yaml`

`\# 查看状态`

`kubectl get svc -n istio-system`

`kubectl get pods -n istio-system`

### 启用自动注入 sidecar

- 不开启自动注入部署应用需要使用如下方式的命令

  `kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/kube/bookinfo.yaml)`

- 开启自动注入后，使用正常命令即可部署应用

  `kubectl apply -f samples/bookinfo/kube/bookinfo.yaml`

```
# k8s 1.9 及之后的版本才能使用
# 查看是否支持
kubectl api-versions | grep admissionregistration

# 除了要满足以上条件外还需要检查kube-apiserver启动的参数
# k8s 1.9 版本要确保 --admission-control 里有 MutatingAdmissionWebhook,ValidatingAdmissionWebhook
# k8s 1.9 之后的版本要确保 --enable-admission-plugins 里有MutatingAdmissionWebhook,ValidatingAdmissionWebhook

# 生成所需要的证书
./install/kubernetes/webhook-create-signed-cert.sh \
    --service istio-sidecar-injector \
    --namespace istio-system \
    --secret sidecar-injector-certs

# 创建配置configmap
kubectl apply -f install/kubernetes/istio-sidecar-injector-configmap-release.yaml

# 生成相关yaml
cat install/kubernetes/istio-sidecar-injector.yaml | \
     ./install/kubernetes/webhook-patch-ca-bundle.sh > \
     install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml

# 安装webhook
kubectl apply -f install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml

# 查看
kubectl -n istio-system get deployment -listio=sidecar-injector
kubectl get namespace -L istio-injection

# 测试自动注入
# 创建
kubectl apply -f samples/sleep/sleep.yaml 
kubectl get deployment -o wide
kubectl get pod

# 设置 default namespace 开启自动注入
kubectl label namespace default istio-injection=enabled
kubectl get namespace -L istio-injection

# 删除创建的pod，等待重建
kubectl delete pod $(kubectl get pod | grep sleep | cut -d ' ' -f 1)

# 查看重建后的pod
# 查看是否有istio-proxy容器
kubectl get pod
kubectl describe pod $(kubectl get pod | grep sleep | cut -d ' ' -f 1)

# 清理
kubectl delete -f samples/sleep/sleep.yaml 

# 关闭自动注入
kubectl label namespace default istio-injection-

# 关闭部分pod的自动注入功能
...
  template:
    metadata:
      annotations:
        sidecar.istio.io/inject: "false"
...
复制代码
```

### 部署官方测试用例

```
# 启动（未开启自动注入）
kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/kube/bookinfo.yaml)

# 启动（已开启自动注入）
kubectl apply -f samples/bookinfo/kube/bookinfo.yaml

# 查看状态
kubectl get services
kubectl get pods
kubectl get ingress -o wide
```

### 访问测试

```
# 命令行访问测试
GATEWAY_URL=$(kubectl get po -l istio=ingress -n istio-system -o 'jsonpath={.items[0].status.hostIP}'):$(kubectl get svc istio-ingress -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')

curl -o /dev/null -s -w "%{http_code}\n" http://${GATEWAY_URL}/productpage

# 浏览器访问测试
NODE_PORT=$(kubectl get svc istio-ingress -n istio-system -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP='11.11.11.112'
echo http://${NODE_IP}:${NODE_PORT}/productpage

# 使用daemonset方式部署可以使用如下方式访问
# 11.11.11.112为其中一个node节点的ip
curl http://11.11.11.112/productpage
```

我们使用Istio提供的测试应用[bookinfo](https://istio.io/docs/samples/bookinfo.html)微服务来进行测试。

该微服务用到的镜像有：

```
istio/examples-bookinfo-details-v1
istio/examples-bookinfo-ratings-v1
istio/examples-bookinfo-reviews-v1
istio/examples-bookinfo-reviews-v2
istio/examples-bookinfo-reviews-v3
istio/examples-bookinfo-productpage-v1
```

该应用架构图如下：

![5c650fff92934](https://i.loli.net/2019/02/14/5c650fff92934.png)

**部署应用**

```
kubectl create -f <(istioctl kube-inject -f samples/apps/bookinfo/bookinfo.yaml)
```

`Istio kube-inject`命令会在`bookinfo.yaml`文件中增加Envoy sidecar信息。参考[https://istio.io/docs/reference/commands/istioctl/#istioctl-kube-inject](https://istio.io/docs/reference/commands/istioctl/#istioctl-kube-inject)

在本机的`/etc/hosts`下增加VIP节点和`ingress.istio.io`的对应信息，具体步骤参考：[边缘节点配置](https://jimmysong.io/kubernetes-handbook/practice/edge-node-configuration.html)，或者使用gateway ingress来访问服务，

如果将`productpage`配置在了ingress里了，那么在浏览器中访问`http://ingress.istio.io/productpage`，如果使用了istio默认的`gateway`ingress配置的话，ingress service使用`nodePort`方式暴露的默认使用32000端口，那么可以使用`http://任意节点的IP:32000/productpage`来访问。

![5c65101e3d504](https://i.loli.net/2019/02/14/5c65101e3d504.png)

![图片 \- BookInfo Sample页面]()

多次刷新页面，你会发现有的页面上的评论里有星级打分，有的页面就没有，这是因为我们部署了三个版本的应用，有的应用里包含了评分，有的没有。Istio根据默认策略随机将流量分配到三个版本的应用上。

查看部署的bookinfo应用中的`productpage-v1`service和deployment，查看`productpage-v1`的pod的详细json信息可以看到这样的结构：

BookInfo示例中有三个版本的`reviews`，可以使用istio来配置路由请求，将流量分发到不同版本的应用上。参考[Configuring Request Routing](https://istio.io/docs/tasks/request-routing.html)。

还有一些更高级的功能，我们后续将进一步探索。

### 监控部署

安装插件

```
kubectl apply -f install/kubernetes/addons/prometheus.yaml
kubectl apply -f install/kubernetes/addons/grafana.yaml
kubectl apply -f install/kubernetes/addons/servicegraph.yaml
kubectl apply -f install/kubernetes/addons/zipkin.yaml
```

上述监控插件分别有普罗米修斯，grafana,servicegraph,和服务流量追踪zipkin.

### 清理

```
# 清理官方用例
samples/bookinfo/kube/cleanup.sh

# 清理istio
kubectl delete -f install/kubernetes/istio.yaml
# kubectl delete -f install/kubernetes/istio-auth.yaml
```
