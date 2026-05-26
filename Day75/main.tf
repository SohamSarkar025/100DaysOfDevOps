provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source              = "./modules/ec2_instance"
  ami_value           = "ami-091138d0f0d41ff90"
  instance_type_value = "t2.micro"
  subnet_id_value     = "subnet-0d98cba5e69bd6e68"
}
