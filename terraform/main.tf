# main.tf

module "networking" {
  source           = "./modules/networking"
  project_name     = var.project_name
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

module "compute" {
  source         = "./modules/compute"
  vpc_id         = module.networking.vpc_id
  subnet_id      = module.networking.subnet_id
  security_group = module.networking.security_group_id
  project_name   = var.project_name
  AWS_SSH_KEY    = var.AWS_SSH_KEY
}

module "dns" {
  source          = "./modules/dns"
  vpc_id          = module.networking.vpc_id
  control_node_ip = module.compute.control_node_private_ip
  managed_ips     = module.compute.managed_node_private_ips
  db_node_ip      = module.compute.db_node_private_ip
}