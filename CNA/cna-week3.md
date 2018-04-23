# CNA H2K Session Week 3

This session walks through the basics of Kubernetes from a consumer perspective.  Please note that some of these commands and config file parameters may be specific to a particular version of Kubernetes, these steps were tested on 1.8.1.  You may have to adapt some items like `apiVersion` to a value suitable for the version of Kubernetes you are using.

## Namespaces
A way to carve up a Kubernetes cluster to provide some level of isolation between Kubernetes objects or in other words create virtual clusters.  We can create a namespace and then via a command line argument or by setting our kubectl context can create objects in that namespace.  If no namespace is specific or set via context then the 'default' namespace is assumed.  Example usage:

```
kubectl create namespace testing
kubectl --namespace=testing run nginx --image=nginx
kubectl get pods --namespace=testing
kubectl delete deployment/nginx --namespace
kubectl delete namespace/testing
```

## Pods
A grouping of one or more containers as an atomic unit of deployment on a Kubernetes cluster.  We can create a running pod using a variety of methods.  First with the kubectl run command:

```
kubectl run nginx --image=nginx
kubectl get pods -o wide # note the IP address
curl <insert ip> # should show text html with Welcome to nginx!
kubectl delete deployments/nginx
```

or with a manifest file:

```
# Paste the following multi-line cat command all in one go to create the yaml file
cat >simple-app.yaml <<EOL
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 8080
      name: http
      protocol: TCP
EOL
# the following commands can be run one at a time
kubectl apply -f simple-app.yaml
kubectl get pods -o wide # note the IP address
curl <insert ip> # should show text html with Welcome to nginx!
kubectl delete -f simple-app.yaml
```

We can create liveness probes to determine the health of containers within a pod.  The probe definition will sit within the deployment yaml config.  There are different types of probes we can create.  The following uses an HTTP Get to check liveness:

```
cat >simple-app-probe.yaml <<EOL
apiVersion: v1
kind: Pod
metadata:
  name: nginxprobe
spec:
  containers:
  - image: nginx
    name: nginx
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      timeoutSeconds: 1
      failureThreshold: 3
    ports:
    - containerPort: 8080
      name: http
      protocol: TCP
EOL
kubectl apply -f simple-app-probe.yaml
kubectl describe pod nginxprobe
# wait a minute or so
kubectl describe pod nginx probe # Since /wrong does not exist event should show container was restarted and probe failing with 404
kubectl delete -f simple-app-probe.yaml
```

Sometimes pods will be required to persist state even after a pod is restarted or killed, an example would be a database service.  We can do this through using `spec.volumes` and `volumeMounts` in our yaml file.  Through these we can mount volumes from network resources like NFS or even local directories on the Kubernetes worker node where the pod is scheduled.  Example:

```
cat >simple-app-storage.yaml <<EOL
apiVersion: v1
kind: Pod
metadata:
  name: nginxstorage
spec:
  volumes:
  - name: "data"
    hostPath:
      path: "/var/log"
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - mountPath: "/data"
      name: "data"
    ports:
    - containerPort: 8080
      name: http
      protocol: TCP
EOL
kubectl apply -f simple-app-storage.yaml
kubectl describe pod nginxstorage
# Wait until pod is fully up
kubectl exec nginxstorage /bin/bash -it
ls
ls /data
exit
kubectl delete -f simple-app-storage.yaml
```

Some useful pod related commands:
- `kubectl describe pods <pod name>`
- `kubectl logs nginx # optional flag -f will stream the logs`
- `kubectl exec nginx date # run commands inside the prod, in this case date. Use -it as the final arg for interactive`
- `kubectl cp ~/file.txt <pod>:/file.txt # to copy a file into a pod, reverse works as well`

## Labels, Annotations & Selectors
Labels and annotations can be used to add metadata to Kubernetes objects.  Roughly speaking labels are used as identifying tags and annotations can be used like notes.  Selectors can be used to group objects with the same label as a set, or collection.

Example Label definition and use of selector for get pods:

```
cat >simple-app-label.yaml <<EOL
apiVersion: v1
kind: Pod
metadata:
  name: nginxlabel
  labels: {
    "stage": "prod",
    "version": "1"
    }
  annotations:
    "reasons": "pod showcase"
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 8080
      name: http
      protocol: TCP
EOL
kubectl apply -f simple-app-label.yaml
kubectl get pods --show-labels
kubectl get pods --selector="stage=prod"
kubectl delete -f simple-app-label.yaml
```

## ReplicaSets
To schedule a pod multiple times to handle performance, availability, or computation distribution, we can replicate a pod deployment by specifying a number of copies to run.  This is better than creating multiple deployments as not only does it save time but also reduces the chance for human error.  ReplicaSet example:

```
cat >simple-app-rs.yaml <<EOL
apiVersion: apps/v1beta2
kind: ReplicaSet
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
        version: "1"
    spec:
      containers:
      - name: nginx
        image: nginx
EOL
kubectl apply -f simple-app-rs.yaml
kubectl get pods
kubectl scale --replicas=5 rs/nginx
kubectl delete -f simple-app-rs.yaml
```

Besides specifying a static number of replicas, we can also auto-scale our ReplicaSets according to available resources such as CPU.

## Service Discovery
For dynamic runtime platforms like Kubernetes, a mechanism is required to both allow for services to obtain a consistent network location and a requestor of services to get that location.  Its important to note IP addressing for Pods is ephemeral and may not persist through the lifecycle of a pod.  We can create a Service object to tackle this problem.

```
cat >simple-app-sd1.yaml <<EOL
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
EOL
kubectl apply -f simple-app-rs.yaml
kubectl apply -f simple-app-sd1.yaml
kubectl get service # Note ClusterIP
kubectl describe service nginx-service # note the associated Pods
kubectl run -i --tty centos --image=centos --restart=Never -- sh
curl nginx-service # should show welcome to nginx
curl <ClusterIP> # should show welcome to nginx
exit
kubectl delete pod centos
curl <ClusterIP>
kubectl delete -f simple-app-sd1.yaml
``` 

You may have noted the Service object creates an internal DNS entry for our service.  If we are consuming this DNS entry within the same namespace then we can just use the service name.  If outside of the namespace then the full address is `<service-name>.<namespace>.svc.cluster.local`.

From the client machine were we able to get a response back from nginx?  If not, then why not?  Looking closely at the IP address provided as ClusterIP.  Would that be routable from your client machine?  Unfortunately no, this ClusterIP is internal to the Kubernetes cluster.  An example where this is useful is connecting Fronts End pods to a collection of Back End pods forming a Back End service.  If we want to create a ClusterIP which is accessible to clients outside of the Kubernetes cluster then we'll need to alter our service definition to use a `NodePort`.

```
cat >simple-app-sd2.yaml <<EOL
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
  type: NodePort
EOL
kubectl apply -f simple-app-sd2.yaml
kubectl get service # Note the port associated to the ClusterIP
kubectl describe service nginx-service
kubectl get nodes -o wide # Note one of the node ip addresses
curl <NodeIP>:<ClusterIP Port>
kubectl delete -f simple-app-sd2.yaml
``` 

In the above case we can access the defined service from any worker node by using the same port.  But what if we want a single IP address for clients to use without limiting them to a single Kubernetes Node?  In this case there's no secret sauce here, we'll need to bring a loadbalancer to the party.  Many loadbalancing solutions exist, some Kubernetes solutions such as Pivotal Container Service with NSX package them in.  To create a loadbalanced service accessible to clients outside of the cluster we can use the type `LoadBalancer`.

```
cat >simple-app-sd3.yaml <<EOL
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
  type: LoadBalancer
EOL
kubectl apply -f simple-app-sd3.yaml
kubectl get service # Note the external IP
curl <ExternalIP>
kubectl delete -f simple-app-sd3.yaml
kubectl delete -f simple-app-rs.yaml
``` 

## DaemonSets
If you want to replicate Pods and to ensure a Pod is scheduled on each worker node in Kubernetes cluster, we can use the DaemonSet object.  A reason to do so may be to run a particular agent like a systems monitoring agent or log collector.

```
cat >simple-app-ds.yaml <<EOL
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-daemon
spec:
  selector:
    matchLabels:
      name: nginx
  template:
    metadata:
      labels:
        name: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
EOL
kubectl apply -f simple-app-ds.yaml
kubectl get pods -o wide # note there is 1 pod for each worker node
kubectl delete -f simple-app-ds.yaml
``` 

## Jobs
A Pod which runs until the process returns a successful termination.  Good for one off runs such as batch jobs.  There are a few types of jobs:
- One Shot: A single pod run
- Parallel Fixed Completions: Multiple pods run in parallel until total count of requested pods complete
- Work Queue: Creates pods to consume items in a work queue

Example one shot job request:

```
cat >simple-app-job.yaml <<EOL
apiVersion: batch/v1
kind: Job
metadata:
  name: bash-job
spec:
  template:
    spec:
      containers:
      - name: bash
        image: centos
        command: [""]
      restartPolicy: Never
EOL
kubectl apply -f simple-app-job.yaml
kubectl describe job bash-job
kubectl delete -f simple-app-job.yaml
``` 

## Singletons
A single instance of a Pod which is not replicated or scaled

## Deployments

## StatefulSets
Replicated Pods where each Pod gets an indexed hostname

## Helpful Links
- https://github.com/mreferre/yelb (Massimo Re Ferre's demo application)
- https://v1-9.docs.kubernetes.io/docs/home/ (Choose the correct version to match your Kubernetes implementation)
