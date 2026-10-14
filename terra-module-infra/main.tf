module "infra" {
  source = "./infra"

  region        = var.region
  ami_id        = var.ami_id
  instance_type = var.instance_type
  vpc_cidr      = var.vpc_cidr
  project_name  = var.project_name
  env           = var.env
}
