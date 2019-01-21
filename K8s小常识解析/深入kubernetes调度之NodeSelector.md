## 深入kubernetes调度之NodeSelector

##### Kubernetes的调度有简单，有复杂，指定NodeName和使用NodeSelector调度是最简单的，可以将Pod调度到期望的节点上。

本文主要介绍kubernetes调度框架中的NodeName和NodeSelector。


### 1 NodeName


Pod.spec.nodeName用于强制约束将Pod调度到指定的Node节点上，这里说是“调度”，但其实指定了nodeName的Pod会直接跳过Scheduler的调度逻辑，直接写入PodList列表，该匹配规则是强制匹配

例子：

    apiVersion: extensions/v1beta1
    kind: Deployment
    metadata:
      name: tomcat-deploy
    spec:
      replicas: 1
      template:
	    metadata:
	      labels:
	    app: tomcat-app
	    spec:
	      nodeName: k8s.node1 #指定调度节点为k8s.node1
	      containers:
	      - name: tomcat
	    image: tomcat:8.0
	    ports:
	    - containerPort: 8080
	    --------------------- 



### 2 NodeSelector

Pod.spec.nodeSelector是通过kubernetes的label-selector机制进行节点选择，由scheduler调度策略MatchNodeSelector进行label匹配，调度pod到目标节点，该匹配规则是强制约束。启用节点选择器的步骤为：


- Node添加label标记

标记规则：kubectl label nodes <node-name> <label-key>=<label-value>


    $kubectl label nodes k8s.node1 cloudnil.com/role=dev

确认标记

    root@k8s.master1:~# kubectl get nodes k8s.node1 --show-labels
    NAMESTATUSAGE   LABELS
    k8s.node1   Ready 29d   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,cloudnil.com/role=dev,kubernetes.io/hostname=k8s.node1



- Pod定义中添加nodeSelector
- 

    apiVersion: extensions/v1beta1
    kind: Deployment
    metadata:
      name: tomcat-deploy
    spec:
      replicas: 1
      template:
	    metadata:
	      labels:
	    app: tomcat-app
	    spec:
	      nodeSelector:
	    	cloudnil.com/role: dev  #指定调度节点为带有label标记为：cloudnil.com/role=dev的node节点
	      containers:
	      - name: tomcat
		    image: tomcat:8.0
		    ports:
		    - containerPort: 8080
