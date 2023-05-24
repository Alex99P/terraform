provider "aws" {
  region = "eu-central-1"
}

variable "vpc_cidr_block" {}
variable "private_subnets_cidr_blocks" {}
variable "public_subnets_cidr_blocks" {}


data "aws_availability_zones" "azs" {}



# this module is imported from registry
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = "myapp-vpc"
  cidr = var.vpc_cidr_block
  private_subnets = var.private_subnets_cidr_blocks
  public_subnets = var.public_subnets_cidr_blocks
#   azs = ["eu-central-1a","eu-central-1b","eu-central-1c"] we have to set dynamicaly
  azs = data.aws_availability_zones.azs.names
  

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

# These tags are required
  tags = {
    "kubernetes.io/cluster/myapp-eks-cluster"= "shared"
  }
  public_subnet_tags = {
     "kubernetes.io/cluster/myapp-eks-cluster"= "shared"
     "kubernetes.io/role/elb"=1
  }
   private_subnet_tags = {
     "kubernetes.io/cluster/myapp-eks-cluster"= "shared"
     "kubernetes.io/role/internal-elb"=1

  }
}