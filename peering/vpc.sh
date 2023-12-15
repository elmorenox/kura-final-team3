#!/bin/bash
########################## AWS CLI CONFIG ##########################################
# Using the credentials created in Jenkins and passing them to aws cli configure 
# must have this setup to have access to AWS account 
aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
aws configure set region us-east-1

# Download the file from S3
aws s3 cp "s3://d10bucket/vpc.txt" .
aws s3 cp "s3://d10bucket/vpcw.txt" .

######################################################################################
east_vpc_id=$(grep "East vpc id:" vpc.txt | awk '{print $NF}')
east_vpc_cidr=$(grep "East vpc cidr:" vpc.txt | awk '{print $NF}')
east_route_table=$(grep "East vpc route:" vpc.txt | awk '{print $NF}')

#######################################################################################
peer_vpc_id=$(grep "peer vpc id:" vpcw.txt | awk '{print $NF}' )
peer_vpc_cidr=$(grep "peer vpc cidr:" vpcw.txt | awk '{print $NF}')
peer_route_table=$(grep "peer vpc route:" vpcw.txt | awk '{print $NF}')

#######################################################################################
# Print the extracted VPC IDs
echo "east_vpc_id = \"$east_vpc_id\"" > terraform.tfvars
echo "east_vpc_cidr = \"$east_vpc_cidr\"" >> terraform.tfvars
echo "east_route_table_id = \"$east_route_table\"" >> terraform.tfvars


#######################################################################################
echo "peer_vpc_id = \"$peer_vpc_id\"" >> terraform.tfvars
echo "peer_vpc_cidr = \"$peer_vpc_cidr\"" >> terraform.tfvars
echo "peer_route_table_id = \"$peer_route_table\"" >> terraform.tfvars

chmod +x ./sg.sh
./sg.sh

terraform init 
terraform plan
terraform apply
