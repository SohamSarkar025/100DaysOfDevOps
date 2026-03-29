provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "test_server" {
  ami           = "ami-0c7217cdde317cfec" 
  instance_type = "t2.micro"
  
  # My Subnet id:
  subnet_id     = "subnet-0d98cba5e69bd6e68" 

  tags = {
    Name = "Soham-Terraform-Day17"
  }
}
