## 基于kubernetes集群部署DashBoard

### Kubernetes1.13.1部署Kuberneted-dashboard v1.10.1



#### 镜像
1、注册阿里云账户构建自己的镜像

可以关联github构建，这样就可以把国外镜像生成为阿里云镜像

    https://github.com/minminmsn/k8s1.13/tree/master/kubernetes-dashboard-amd64/Dockerfile

2、下载docker镜像

    $docker pull registry.cn-beijing.aliyuncs.com/minminmsn/kubernetes-dashboard:v1.10.1

#### SSL证书

证书不对或者用auto创建的证书会报错，报错见https://github.com/kubernetes/dashboard/issues/3472

1、如果购买有的证书的话，把证书文件放在certs/目录下创建secret即可

    [root@elasticsearch01 /]# ls certs/
    minminmsn.crt  minminmsn.csr  minminmsn.key
    
    [root@elasticsearch01 /]# kubectl create secret generic kubernetes-dashboard-certs --from-file=certs -n kube-system
    secret/kubernetes-dashboard-certs created


2、如果没有购买的话需要自定义生成证书，步骤如下

    [root@elasticsearch01 /]# mkdir /certs
    [root@elasticsearch01 /]# openssl req -nodes -newkey rsa:2048 -keyout certs/dashboard.key -out certs/dashboard.csr -subj "/C=/ST=/L=/O=/OU=/CN=kubernetes-dashboard"
    Generating a 2048 bit RSA private key
    ................+++
    ..............................................+++
    writing new private key to 'certs/dashboard.key'
    -----
    No value provided for Subject Attribute C, skipped
    No value provided for Subject Attribute ST, skipped
    No value provided for Subject Attribute L, skipped
    No value provided for Subject Attribute O, skipped
    No value provided for Subject Attribute OU, skipped
    [root@elasticsearch01 /]# ls /certs
    dashboard.csr  dashboard.key
    
    [root@elasticsearch01 /]# openssl x509 -req -sha256 -days 365 -in certs/dashboard.csr -signkey certs/dashboard.key -out certs/dashboard.crt
    Signature ok
    subject=/CN=kubernetes-dashboard
    Getting Private key
    [root@elasticsearch01 /]# ls certs/
    dashboard.crt  dashboard.csr  dashboard.key
    
    [root@elasticsearch01 /]# kubectl create secret generic kubernetes-dashboard-certs --from-file=certs -n kube-system
    secret/kubernetes-dashboard-certs created

端口暴露：修改service配置，将type: ClusterIP改成NodePort,便于通过Node端口访问

    [root@elasticsearch01 /]# wget https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
    [root@elasticsearch01 /]# vim /k8s/yaml/kubernetes-dashboard.yaml 
    kind: Service
    apiVersion: v1
    metadata:
      labels:
    k8s-app: kubernetes-dashboard
      name: kubernetes-dashboard
      namespace: kube-system
    spec:
      type: NodePort
      ports:
    - port: 443
      targetPort: 8443
      selector:
    k8s-app: kubernetes-dashboard

### 部署Kubernetes-dashboard
修改镜像地址为registry.cn-beijing.aliyuncs.com/minminmsn/kubernetes-dashboard:v1.10.1即可部署


    [root@elasticsearch01 /]# vim /k8s/yaml/kubernetes-dashboard.yaml 
    spec:
      containers:
      - name: kubernetes-dashboard
    image: registry.cn-beijing.aliyuncs.com/minminmsn/kubernetes-dashboard:v1.10.1
    
    
    [root@elasticsearch01 /]# kubectl create -f /k8s/yaml/kubernetes-dashboard.yaml 
    serviceaccount/kubernetes-dashboard created
    role.rbac.authorization.k8s.io/kubernetes-dashboard-minimal created
    rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard-minimal created
    deployment.apps/kubernetes-dashboard created
    service/kubernetes-dashboard created
    Error from server (AlreadyExists): error when creating "/k8s/yaml/kubernetes-dashboard.yaml": secrets "kubernetes-dashboard-certs" already exists
    
    
    [root@elasticsearch01 /]# kubectl get pods -n kube-system
    NAME   READY   STATUSRESTARTS   AGE
    kubernetes-dashboard-cb55bd5bd-4jsh7   1/1 Running   0  21s
    [root@elasticsearch01 /]# kubectl get svc -n kube-system
    NAME   TYPE   CLUSTER-IP   EXTERNAL-IP   PORT(S) AGE
    kubernetes-dashboard   NodePort   10.254.140.115   <none>443:41579/TCP   31s
    [root@elasticsearch01 /]# kubectl get pods -n kube-system -o wide
    NAME   READY   STATUSRESTARTS   AGE   IPNODENOMINATED NODE   READINESS GATES
    kubernetes-dashboard-cb55bd5bd-4jsh7   1/1 Running   0  40s   10.254.73.2   10.2.8.34   <none>   <none>
    
### 访问dashboard

1、注意有证书需要域名访问，如果有DNS可以配置域名解析，没有Host绑定即可

2、选择token访问，token获取方法如下

    [root@elasticsearch01 ~]# cat /k8s/yaml/admin-token.yaml 
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1beta1
    metadata:
      name: admin
      annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
    roleRef:
      kind: ClusterRole
      name: cluster-admin
      apiGroup: rbac.authorization.k8s.io
    subjects:
    - kind: ServiceAccount
      name: admin
      namespace: kube-system
    ---
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: admin
      namespace: kube-system
      labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    
查看token

    [root@elasticsearch01 yaml]# kubectl create -f admin-token.yaml 
    clusterrolebinding.rbac.authorization.k8s.io/admin created
    serviceaccount/admin created


    [root@k8s-master Dashboard]# kubectl describe secret/$(kubectl get secret -nkube-system |grep admin|awk '{print $1}') -nkube-system
    Name: admin-token-5qkp4
    Namespace:kube-system
    Labels:   <none>
    Annotations:  kubernetes.io/service-account.name: admin
      kubernetes.io/service-account.uid: c172f835-131b-11e9-aba1-000c294ad95a
    
    Type:  kubernetes.io/service-account-token
    
    Data
    ====
    ca.crt: 1025 bytes
    namespace:  11 bytes
    token:  eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi10b2tlbi01cWtwNCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJhZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImMxNzJmODM1LTEzMWItMTFlOS1hYmExLTAwMGMyOTRhZDk1YSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTphZG1pbiJ9.UctdJougnSQxTk44Rq_UVb5Fco9qoInlPDvQniBnaPeOh1Uc1YOjU6Mp-uDsar5rS6mDTdvNbbnI1M8BddMGN_O6yVpaRVMpv7SfkZrLQ3Rf5wVPW6N9KkhU8p8HBWtCiBJnIOFgF0ivPwckKOAAN5-3FGwRyhJ5wWta8p5zSxoiEmrTUumF0Z3PJpBi-gqvTMuNyi9t6X--aJjSl7y4tub6pT59pHKYWrKFytqtPpjPCAC-RHupwwaOkjARVFxcrahH0hIcBKrxtiOxecltudwoE_o1ZzqzskQ7HYal25rbNf6PReurBt26wipPJqr7dO7LcO8j2ObPrrDLGC4WKw


#### 后续：
因为访问需要所有的网页请求都必须要https，所以谨记一点访问时使用https进行访问：

    https://192.168.131.10:30810
之后输入我们得到的token，进行登录验证。


##### 参考链接：https://www.jianshu.com/p/78c9642af72f
