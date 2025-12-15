# Kubernetes-in-Kubernetes

Kubernetes-in-Kubernetes a.k.a **KinK** is a way to run a Kubernetes control-plane over an existing Kubernetes cluster.
Pretty useless if you ask me...

Currently, the only components that are up and running are
- etcd (a statefulset of single replica, yes I know)
- kube-apiserver
- kube-controller-manager


This chart rely on [cert-manager](https://cert-manager.io/).


# Usage

Install the chart for local development (usually w minikube)
```shell
helm install -n kink --create-namespace charts/kink
```

```shell
mkdir -p ./kink-certs

kubectl -n kink get secret kink-admin -o template='{{index .data "tls.key" }}'  | base64 -d > ./kink-certs/tls.key
kubectl -n kink get secret kink-admin -o template='{{index .data "tls.crt" }}' | base64 -d > ./kink-certs/tls.crt
kubectl -n kink get secret kink-root-ca -o template='{{index .data "ca.crt" }}' | base64 -d > ./kink-certs/ca.crt

kubectl config set-cluster kink \
    --certificate-authority=./kink-certs/ca.crt \
    --embed-certs=true \
    --server=https://kubernetes.local:30443 \
    --kubeconfig=kink.kubeconfig

kubectl config set-credentials admin \
    --client-certificate=./kink-certs/tls.crt \
    --client-key=./kink-certs/tls.key \
    --embed-certs=true \
    --kubeconfig=kink.kubeconfig

kubectl config set-context default \
    --cluster=kink \
    --user=admin \
    --kubeconfig=kink.kubeconfig

kubectl config use-context default \
    --kubeconfig=kink.kubeconfig

kubectl --kubeconfig kink.kubeconfig get all
```
