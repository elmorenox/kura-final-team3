#!/bin/bash
########################### SUBNET ID ###############################################
# Retrieve subnet IDs from Terraform
# Output were created  in terraform file and now saved in variables

subnet_id_public_a=$(terraform output -raw subnet_id_public_a)
subnet_id_public_b=$(terraform output -raw subnet_id_public_b)
subnet_id_private_a=$(terraform output -raw subnet_id_private_a)
subnet_id_private_b=$(terraform output -raw subnet_id_private_b)
# Outputs are local to the initTerra dir

vpc_idw=$(terraform output -raw d10_vpcw_id) 
vpcw_cidr=$(terraform output -raw vpc_cidr)
vpcw_route=$(terraform output -raw private_route_id)
echo "peer vpc id: $vpc_idw" > vpcw.txt
echo "peer vpc cidr: $vpcw_cidr" >> vpcw.txt 
echo "peer vpc route: $vpcw_route" >> vpcw.txt
aws s3 cp vpcw.txt s3://d10bucket/

# Kuber dir has all the necessary files
cd ../kubernetes/
########################## AWS CLI CONFIG ##########################################
# Using the credentials created in jenkins and passing them to aws cli configure 
# must have this setup to have access to aws account 
aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
aws configure set region us-west-1
######################### CLUSTER CREATION ###########################################
#creating a cluster given the subnet id that has been stored in variables
eksctl create cluster cluster02 --vpc-private-subnets=$subnet_id_private_a,$subnet_id_private_b --vpc-public-subnets=$subnet_id_public_a,$subnet_id_public_b --without-nodegroup
#create cluster of size t2.med
eksctl create nodegroup --cluster cluster02 --node-type t2.2xlarge --nodes 2 
# apply deployment yaml which creates app based on instructions 
#the service yaml takes care of ports and how traffic will get to the deployment
kubectl apply -f recipe-generator-deployment.yaml
kubectl apply -f recipe-generator-service.yaml

sleep 240s
################################ ALB CONFIG ####################################################
#creates iam provider so that eks can connect to IAM
eksctl utils associate-iam-oidc-provider --cluster cluster02 --approve

#create policy given the json file 
# capture the output 

output=$(aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy1 --policy-document file://iam_policy.json)

# Extract the ARN from the output using grep or other string manipulation
arn=$(echo "$output" | jq -r '.Policy.Arn')

## figure out how to add arn here from the previous command to fully automate
## Use varaibale to create iam service
eksctl create iamserviceaccount --cluster=cluster02 --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn="$arn" --override-existing-serviceaccounts --approve
############################# YAML FILES ###############################################
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml
sleep 30s
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds"
sleep 30s
kubectl apply -f v2_4_7_full.yaml
sleep 30s
kubectl apply -f ingressClass.yaml  
sleep 30s
kubectl apply -f ingress.yaml

kubectl apply -f redis-follower-configmap.yaml

kubectl apply -f nginx-proxy-service.yaml

kubectl apply -f redis-follower-service.yaml 

kubectl apply -f nginx-config.yaml

kubectl apply -f nginx-deployment.yaml

kubectl apply -f redis-follower-statefulset.yaml

kubectl apply -f celery-deployment.yaml

kubectl apply -f recipe-generator-hpa.yaml

eksctl create iamidentitymapping  --region us-west-1 --cluster cluster02  --arn arn:aws:iam::294733426135:role/eks-lambda-role --username admin --group system:masters

aws lambda invoke --function-name kubectl-update-config --invocation-type Event --payload fileb://event.json --region us-east-1 response.json
