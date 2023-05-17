# providers need to be installed
provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name: "${var.env_prefix}-vpc"
    }
}


module "myapp-subnet" {
  source = "./modules/subnet"
  subnet_cidr_block= var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.myapp-vpc.id
}

module "myapp-server" {
  source = "./modules/webserver"
  vpc_id=aws_vpc.myapp-vpc.id
  subnet_id= module.myapp-subnet.subnet.id
  my_ip= var.my_ip
  env_prefix= var.env_prefix
  image_name = var.image_name
  public_key_location=var.public_key_location
  instance_type = var.instance_type
  avail_zone= var.avail_zone
}
