


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.14.0"

  cluster_name = "myapp-eks-cluster"
  cluster_version = "1.25"

# in private subnets workload will be scheduled
  subnet_ids = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  tags = {
    environment= "development"
    application= "myapp"
  }

  eks_managed_node_groups = {
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t2.micro"]
    }
  }
 
#   create_aws_auth_configmap = true

aws_auth_users = [
    {
      userarn  = "arn:aws:iam::655040030455:user/root"
      username = "root"
      groups   = ["system:masters"]
    },
  ]
}