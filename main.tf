# providers need to be installed
provider "aws" {
  region = "eu-central-1"
}

variable "cidr_blocks" {
    description = "cidr blocks and name for vpc and subnets"
    type = list(object({
      cidr_block = string
      name= string 
    }))
  
}
variable "development" {
  description = "development"
}

resource "aws_vpc" "development_vpc" {
    cidr_block = var.cidr_blocks[0].cidr_block
    # cidr_block = "172.2.0.0/16"
    tags = {
      Name: var.cidr_blocks[0].name  # this tag it's reserved for name of resource
    #   vpc_env: "dev"
    }
}

resource "aws_subnet" "dev-subent-1" {
    # in this way a reference is made to the vpc whic doesn't yet exist
  vpc_id = aws_vpc.development_vpc.id 
  cidr_block = var.cidr_blocks[1].cidr_block  #to call a var
  availability_zone = "eu-central-1a"
    tags = {
     Name: var.cidr_blocks[1].name
    }
}

# data basically lets you query the existing resources and componets
# export of query is exported under your given name
data "aws_vpc" "existing_vpc" {
  default = true
}

# name must be unique for each resource type
resource "aws_subnet" "dev-subent-2" {
# we reference at the results of query
  vpc_id = data.aws_vpc.existing_vpc.id
  cidr_block = "172.31.48.0/20"
  availability_zone = "eu-central-1a"
    tags = {
      Name: "subent-1-default"
    }
}

output "dev-vpc-id" {
    value = aws_vpc.development_vpc.id
}
output "dev-subent-id" {
    value = aws_subnet.dev-subent-1.id
}

# resource = create something
# data = return something already exist