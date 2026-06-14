# we use this eks by given module
# EKS Managed Node Group, https://github.com/terraform-aws-modules/terraform-aws-eks

resource "aws_key_pair" "eks" {
  key_name   = "expense-eks"
  public_key ="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDACmnQRYyTnh4wNKgVW9dON9b8lpwKerFoG2ZZgsyhPiidmP1oD1lVl5ANQ7D0HFMdaR7dR3VHNpjjcgwjs9m3UXWTudDoG8r8iIH0uRhSQJoYvExmjNcLXtr6oWyaQoFGH3eYozYo/wlTLPqyG0+STBPXnT58xST+5ZsdbPuCvuAnBt8pm0wGq1QfhZu3w1GIrWbwDJszANDzCR7EaCG8mrN2csrtGthZDWAzG+fct15BU+IMGzIfvIjsGjVCTsL0ZSw9P/3x/6x/EJg0kO5aGCIqo4o69ohXkJN5o6RnfqhmXV6zTXR+aCmIAL9nRCqUVMlhRaKUutbfQ7xxX0zCxZef+R5MzXpaw65QWi/1UvdzNznUguF2XkPr9Qizfs7tfHDPSiicOb0Q4LT7fjS71KgshRiqP2AM7qK2vzpY5HSuOv82Zth1TKiXpmh+MVC7SgXWbalyj4pBEGgC9qzG9QniJj82jhWV69E0ciKUEarOD4vlZbXuFKL+2kmup0uAIjoo8ZD8spcdQsC+moWlqOdhhqWmzspqfkaiFgvXojYsNapVGry4o8713DeUYZL+Cre1St1ZD7b1KIUgLLVa0+UAzQOUVnvx1EFpZ77jCr4vh7kBeHQ6gzTZ9kq0NVELCbj8RPkCF7bX5KbCTMIrF5J0JZxq+cHoN833Hh0haw== ec2-user@ip-172-31-30-123.ec2.internal"

}

   module "eks" {
   source  = "terraform-aws-modules/eks/aws"
   version = "~> 20.0" 

  cluster_name    = local.name
  cluster_version = "1.32" # later we upgrade 1.32
  create_node_security_group = true
  # create_cluster_security_group = true
  # cluster_security_group_id = local.eks_control_plane_sg_id
  # node_security_group_id = local.eks_node_sg_id

  #bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    metrics-server = {}
  }

  # Optional
  cluster_endpoint_public_access = false

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    blue = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      #ami_type       = "AL2_x86_64"
      instance_types = ["t3.medium"]
      key_name = aws_key_pair.eks.key_name

      min_size     = 2
      max_size     = 2
      desired_size = 2
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
    } 

    # green = {
    #   # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
    #   #ami_type       = "AL2_x86_64"
    #   instance_types = ["m5.xlarge"]
    #   key_name = aws_key_pair.eks.key_name

    #   min_size     = 2
    #   max_size     = 10
    #   desired_size = 2
    #   # Worker Node Policies
    #   iam_role_additional_policies = {   
    #     AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #     AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
    #     AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    #   }
    # } 
  }

  tags = merge(
    var.common_tags,
    {
        Name = local.name
    }
  )
   }