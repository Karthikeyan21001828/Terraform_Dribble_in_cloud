provider "aws" {
  region = "eu-north-1"
}

module "app_server" {
  source        = "./modules/app_server"
  vpc_id        = "vpc-024e76b5f8ee97841"
  ami_id         = "ami-04cdc91e49cb06165"
  instance_type  = "t3.medium"
  key_name       = "DevOpsKeyPair"
}

output "app_server_ip" {
  value = module.app_server.instance_public_ip
}
