module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.19.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.27"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  # Enable EKS Control Plane Logs
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  cloudwatch_log_group_retention_in_days = 30  # Adjust as needed

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"
      instance_types = ["t3.small"]
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
    two = {
      name = "node-group-2"
      instance_types = ["t3.small"]
      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}
