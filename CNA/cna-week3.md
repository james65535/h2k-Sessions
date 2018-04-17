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
kubectl delete rs nginx
```

Besides specifying a static number of replicas, we can also auto-scale our ReplicaSets according to available resources such as CPU.


## Service Discovery
For dynamic runtime platforms like Kubernetes, a mechanism is required to both allow for services to register their location and requestor of services to get that location.  The Kubernetes Service Discovery construct provides a great alternative to DNS.  To create a Service, we define a Service Object which will create a clustered IP address for a set of pods which match the appropriate label selector.  The members of the cluster will be loadbalanced by the kube-proxy service which exists on the Kubernetes worker nodes.  We can then hand this cluster IP address to the inbuilt Kubernetes DNS service and let clients resolve from there.  Example Service Object definition:

```

``` 

## DaemonSets
A Pod manager to ensure a Pod is scheduled across a Cluster Node set

## StatefulSets
Replicated Pods where each Pod gets an indexed hostname

## Jobs
A Pod which runs until the process returns a successful termination

## Singletons
A single instance of a Pod which is not replicated or scaled

## Deployments

## Helpful Links
- https://github.com/mreferre/yelb (Massimo Re Ferre's demo application)
