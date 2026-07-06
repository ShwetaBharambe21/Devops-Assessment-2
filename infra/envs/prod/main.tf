module "network" {
  source = "../../modules/network"

  environment = "prod"

  vpc_cidr = "10.1.0.0/16"

  public_subnets = [
    "10.1.1.0/24",
    "10.1.2.0/24"
  ]

  private_subnets = [
    "10.1.11.0/24",
    "10.1.12.0/24"
  ]

  availability_zones = [
    "ap-south-1a",
    "ap-south-1b"
  ]
}

module "ecs" {
  source = "../../modules/ecs"

  environment = "prod"

  vpc_id = module.network.vpc_id

  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
}

module "rds" {
  source = "../../modules/rds"

  environment = "prod"

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  db_instance_class       = "db.t3.small"
  backup_retention_period = 7
  deletion_protection     = true
}