provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-091138d0f0d41ff90"
  instance_type = "t2.micro"
  key_name      = "linux-for-devops-key"
  subnet_id     = "subnet-0d98cba5e69bd6e68"
}
