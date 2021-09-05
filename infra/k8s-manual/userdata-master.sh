#!/bin/bash

set -xe

##################### ALL-CONTAINERD #####################
modprobe overlay
modprobe br_netfilter
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
apt-get update -y
apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/\(SystemdCgroup\s*=\s*\).*$/\1true/' /etc/containerd/config.toml
systemctl restart containerd

############ K8s PACKAGES ############
#Install Kubernetes packages - kubeadm, kubelet and kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
bash -c 'cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF'
apt-get update -y
VERSION=1.21.0-00
apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
apt-mark hold kubelet kubeadm kubectl containerd
systemctl enable kubelet.service
systemctl enable containerd.service

############ CLUSTER CONFIGURATION ############
kubeadm config print init-defaults | tee ClusterConfiguration.yaml
LOCAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i "s/  advertiseAddress: 1.2.3.4/  advertiseAddress: ${LOCAL_IP}/" ClusterConfiguration.yaml
sed -i 's/  criSocket: \/var\/run\/dockershim\.sock/  criSocket: \/run\/containerd\/containerd\.sock/' ClusterConfiguration.yaml
sed -i "s/  name: node/  name: ${HOSTNAME}/" ClusterConfiguration.yaml
sed -i 's/\(kubernetesVersion:\s*\).*$/\11.21.0/' ClusterConfiguration.yaml
cat <<EOF | cat >> ClusterConfiguration.yaml
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF

############ CLUSTER INITIALIZATION ############
kubeadm init \
    --config=ClusterConfiguration.yaml \
    --cri-socket /run/containerd/containerd.sock
export KUBECONFIG=/etc/kubernetes/admin.conf

############ CALICO ############
wget https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f calico.yaml

############ Kubeconfig for Ubuntu user ############
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# To get join token
# kubeadm token create --print-join-command
