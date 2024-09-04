provider "aws" {
  region = "eu-north-1"
}

module "app_server" {
  source        = "./modules/app_server"
  
}

output "app_server_ip" {
  value = module.app_server.instance_public_ip
}
