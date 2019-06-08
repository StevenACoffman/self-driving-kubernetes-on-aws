#!/bin/bash -e

# comment or alter next line to use different region
AWS_DEFAULT_REGION="us-east-1"
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-${AWS_REGION:-"us-east-1"}}
AWS_REGION=${AWS_DEFAULT_REGION}

#randomly picking a letter for initial availability zone
#var="abc"
#AZ_LETTER="${var:$(( RANDOM % ${#var} )):1}"

# everyone's AWS account zone letters are randomly assigned, so just go with A

###############################################################################
### PRE-FLIGHT CHECKS

prerequisites=( aws kubectl docker curl git aws-iam-authenticator jq eksctl)
for i in "${prerequisites[@]}"
do
    if [ ! -x "$(command -v $i)" ]; then
        echo "$i not found. Try:"
        if [[ $i == *"docker"* ]]; then
          echo "brew cask install docker"
      elif [[ $i == *"aws"* ]]; then
          echo "brew install awscli"
        else
          echo "brew install $i"
        fi
        exit 1
    fi
done

###############################################################################
### REAL STUFF

echo Creating cluster in region ${AWS_REGION}
echo ""
echo "NOTE: In us-east-1 you are likely to get UnsupportedAvailabilityZoneException. If you do, copy the suggested zones and pass --zones flag, e.g. eksctl create cluster --region=us-east-1 --zones=us-east-1a,us-east-1b,us-east-1d. This may occur in other regions, but less likely. You shouldn't need to use --zone flag otherwise"
echo ""
echo eksctl create cluster --region=${AWS_REGION} --zones=us-east-1a,us-east-1b,us-east-1c --node-zones=us-east-1a --nodes-min=1 --nodes-max=3 --asg-access --auto-kubeconfig
echo ""
eksctl create cluster --region=${AWS_REGION} --zones=us-east-1a,us-east-1b,us-east-1c --node-zones=us-east-1a --nodes-min=1 --nodes-max=3 --asg-access --auto-kubeconfig

CLUSTER_NAME="$(eksctl get cluster --region=$AWS_REGION | sed -n 2p | awk '{print $1}')"

AWS_PATH="/usr/local/bin"
AWS_BIN="${AWS_PATH}/aws"
AWS_ACCOUNT_ID="$(${AWS_BIN} sts get-caller-identity --output text --query 'Account')"

echo "eksctl config file written to $HOME/.kube/eksctl/clusters/${CLUSTER_NAME} so:"
echo "export KUBECONFIG=$HOME/.kube/eksctl/clusters/${CLUSTER_NAME}"
echo ""
echo "Apply basic cluster infrastructure with:"
echo "./init-cluster.sh"
echo ""
echo "to cleanup all resources, run: eksctl delete cluster --region=${AWS_REGION} --name=${CLUSTER_NAME}"
