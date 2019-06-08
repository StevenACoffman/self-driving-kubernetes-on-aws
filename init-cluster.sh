#!/usr/bin/env bash

set -e

AWS_DEFAULT_REGION="us-east-1"
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-${AWS_REGION:-"us-east-1"}}
AWS_REGION=${AWS_DEFAULT_REGION}
export CLUSTER_NAME="$(eksctl get cluster --region=$AWS_REGION | sed -n 2p | awk '{print $1}')"

export KUBECONFIG="$HOME/.kube/eksctl/clusters/${CLUSTER_NAME}"

AWS_PATH="/usr/local/bin"
echo Initializing base cluster infrastructure for $CLUSTER_NAME in $AWS_REGION

echo "Applying prometheus operator manifests"
kubectl apply -f kube-prometheus/manifests/
echo "Applying Cluster Autoscaler"
./make-cluster-autoscaler.sh

echo "Applying node-problem-detector manifests"
kubectl apply -f node-problem-detector/
echo "Applying draino"
kubectl apply -f draino.yaml
