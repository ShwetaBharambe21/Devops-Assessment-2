resource "aws_security_group" "rds" {
  name   = "${var.environment}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"

    # For a production setup, this should reference the ECS security group
    # instead of 0.0.0.0/0.
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {

  identifier = "${var.environment}-postgres"

  engine = "postgres"

  engine_version = "16"

  instance_class = var.db_instance_class

  allocated_storage = 20

  storage_type = "gp3"

  db_name = "hoteldb"

  username = "postgres"

  password = "Password@123"

  publicly_accessible = false

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  backup_retention_period = var.backup_retention_period

  deletion_protection = var.deletion_protection

  skip_final_snapshot = true
}