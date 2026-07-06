module "network" {
  source = "../../modules/network"

  environment = var.environment

  vpc_cidr = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnets = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]

  availability_zones = [
    "ap-south-1a",
    "ap-south-1b"
  ]
}

module "ecs" {
  source = "../../modules/ecs"

  environment = var.environment

  vpc_id = module.network.vpc_id

  public_subnet_ids = module.network.public_subnet_ids

  private_subnet_ids = module.network.private_subnet_ids
}

module "rds" {
  source = "../../modules/rds"

  environment = var.environment

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  db_instance_class       = "db.t3.micro"
  backup_retention_period = 1
  deletion_protection     = false
}