variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}


resource "aws_iam_role" "redis-eks-role" {
  name = "redis-eks-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "redis-eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.redis-eks-role.name
}

resource "aws_eks_cluster" "redis-eks-cluster" {
  name     = "redis-eks-cluster"
  role_arn = aws_iam_role.redis-eks-role.arn

  vpc_config {
    subnet_ids = [
      var.subnet_ids[0], var.subnet_ids[1]
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.redis-eks-AmazonEKSClusterPolicy]
}


resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_eks_node_group" "private-node" {
  cluster_name    = aws_eks_cluster.redis-eks-cluster.name
  node_group_name = "private-node"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    var.subnet_ids[0],
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t2.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  # taint {
  #   key    = "team"
  #   value  = "devops"
  #   effect = "NO_SCHEDULE"
  # }

  # launch_template {
  #   name    = aws_launch_template.eks-with-disks.name
  #   version = aws_launch_template.eks-with-disks.latest_version
  # }

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# resource "aws_launch_template" "eks-with-disks" {
#   name = "eks-with-disks"

#   key_name = "local-provisioner"

#   block_device_mappings {
#     device_name = "/dev/xvdb"

#     ebs {
#       volume_size = 50
#       volume_type = "gp2"
#     }
#   }
# }


data "tls_certificate" "eks" {
  url = aws_eks_cluster.redis-eks-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.redis-eks-cluster.identity[0].oidc[0].issuer
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.redis-eks-cluster.arn
}

output "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  value       = aws_iam_role.redis-eks-role.arn
}

output "node_role_arn" {
  description = "ARN of the IAM role for the EKS node group"
  value       = aws_iam_role.nodes.arn
}