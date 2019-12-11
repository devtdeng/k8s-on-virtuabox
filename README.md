# Kubernetes Clusters with Vagrant + Virtualbox

## Requirements Host
* Vagrant
* VirtualBox
* 5GB free RAM

## Setup

### Single script

```
$ vagrant destroy -f   # remove previous setup
$ ./scripts/setup      # takes about 15 minutes or more
[...]
```

### Multiple scripts

Execute command line in `./scripts/setup` step by step.

## Using the cluster

### Check cluster status

```
$ kubectl get nodes -o wide
NAME           STATUS   ROLES    AGE   VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
controller-0   Ready    master   49m   v1.17.0   192.168.199.10   <none>        Ubuntu 16.04.6 LTS   4.4.0-169-generic   docker://18.6.2
controller-1   Ready    master   48m   v1.17.0   192.168.199.11   <none>        Ubuntu 16.04.6 LTS   4.4.0-169-generic   docker://18.6.2
controller-2   Ready    master   48m   v1.17.0   192.168.199.12   <none>        Ubuntu 16.04.6 LTS   4.4.0-169-generic   docker://18.6.2
worker-0       Ready    <none>   46m   v1.17.0   192.168.199.20   <none>        Ubuntu 16.04.6 LTS   4.4.0-169-generic   docker://18.6.2
worker-1       Ready    <none>   45m   v1.17.0   192.168.199.21   <none>        Ubuntu 16.04.6 LTS   4.4.0-169-generic   docker://18.6.2
worker-2       Ready    <none>   44m   v1.17.0   192.168.199.22   <none>        Ubuntu 16.04.6 LTS   4.4.0-169-generic   docker://18.6.2


$ kubectl get all
NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
service/kubernetes   ClusterIP   10.32.0.1     <none>        443/TCP          3h24m
```

### Setup DNS add-on

Deploy the DNS add-on and verify it's working:

```
kubectl create -f ./manifests/kube-dns.yaml
[...]
kubectl get pods -l k8s-app=kube-dns -n kube-system
[...]
kubectl run busybox --image=busybox:1.28 --command -- sleep 3600
[...]
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
kubectl exec -ti $POD_NAME -- nslookup kubernetes
```

### Deploy service with Ingress Controller

```
$ kubectl apply -f ./manifests/nginx-ingress.yaml
ingress.extensions/nginx created
deployment.apps/nginx created
service/nginx created

# Access the service via Ingress Controller IP
$ curl -H "Host: nginx.virtualbox" 192.168.199.30
<!DOCTYPE html>
...
</html>
```

### Deploy service with persistent volume

```
$ kubectl apply -f ./manifests/postgresql.yaml 
configmap/cm-psql created
persistentvolume/pv-psql created
persistentvolumeclaim/pvc-psql created
deployment.apps/deployment-psql created
service/svc-psql created

# logon at NodeIP 192.168.199.20/21/22
$ psql db -h 192.168.199.20 -p 30100 -U user
Password for user user:    # type "password"
psql (12.1)
Type "help" for help.
db=# 
```

## Cleanup

### Pause virtual machines

`vagrant suspend -a`

### Delete virtual machines

`vagrant destroy -f`

