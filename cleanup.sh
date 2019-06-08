#!/bin/bash -e
AWS_DEFAULT_REGION="us-east-1"
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-${AWS_REGION:-"us-east-1"}}
AWS_REGION=${AWS_DEFAULT_REGION}
export CLUSTER_NAME="$(eksctl get cluster --region=$AWS_REGION | sed -n 2p | awk '{print $1}')"

export KUBECONFIG="$HOME/.kube/eksctl/clusters/${CLUSTER_NAME}.yaml"

export ASDF_KUBECTL_VERSION=1.12.7
eksctl utils write-kubeconfig --name=${CLUSTER_NAME}
eksctl delete cluster --region=${AWS_REGION} --name=${CLUSTER_NAME}
