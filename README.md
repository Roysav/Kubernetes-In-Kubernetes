# Kubernetes-in-Kubernetes

Kubernetes-in-Kubernetes a.k.a **KinK** is a way to run a Kubernetes control-plane over an existing Kubernetes cluster.
Pretty useless if you ask me...

Currently, the only components that are up and running are
- etcd (a statefulset of single replica, yes I know)
- kube-apiserver
- kube-controller-manager


This chart rely on [cert-manager](https://cert-manager.io/).