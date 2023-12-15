#!/bin/bash

# Specify the EKS cluster name
eks_cluster_name="cluster01"
eks_cluster_namew="cluster02"

# Fetch instance ID and associated security group ID for us-east-1
instance_id1=$(aws ec2 describe-instances --region "us-east-1" --filters "Name=tag:aws:eks:cluster-name,Values=$eks_cluster_name" --query 'Reservations[].Instances[0].InstanceId' --output text)
security_group_id1=$(aws ec2 describe-instances --region "us-east-1" --instance-ids $instance_id1 --query 'Reservations[].Instances[].SecurityGroups[].GroupId' --output text)

# Fetch instance ID and associated security group ID for us-west-1
instance_id2=$(aws ec2 describe-instances --region "us-west-1" --filters "Name=tag:aws:eks:cluster-name,Values=$eks_cluster_namew" --query 'Reservations[].Instances[0].InstanceId' --output text)
security_group_id2=$(aws ec2 describe-instances --region "us-west-1" --instance-ids $instance_id2 --query 'Reservations[].Instances[].SecurityGroups[].GroupId' --output text)

output=$(echo "Security Group ID 1: $security_group_id1")
output2=$(echo "Security Group ID 2: $security_group_id2")

# Extract security group IDs and format them
security_group_id1=$(echo "$output" | awk '/Security Group ID 1/{gsub(/ /, "", $NF); print $NF}')
security_group_id2=$(echo "$output2" | awk '/Security Group ID 2/{gsub(/ /, "", $NF); print $NF}')

# Echo the security group IDs into terraform.tfvars
echo "east_node_sg_id = '$security_group_id1'" >> terraform.tfvars
echo "west_node_sg_id = '$security_group_id2'" >> terraform.tfvars