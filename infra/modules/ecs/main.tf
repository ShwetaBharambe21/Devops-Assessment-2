resource "aws_ecs_cluster" "this" {
  name = "${var.environment}-ecs-cluster"

  tags = {
    Name = "${var.environment}-ecs-cluster"
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.environment}"
  retention_in_days = 7
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {

  role = aws_iam_role.ecs_task_execution.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app" {

  family = "${var.environment}-task"

  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  cpu = 256

  memory = 512

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "nginx"

      image = var.container_image

      essential = true

      portMappings = [
        {
         containerPort = var.container_port
         hostPort      = var.container_port
        }
      ]

      logConfiguration = {

        logDriver = "awslogs"

        options = {

          awslogs-group = aws_cloudwatch_log_group.ecs.name

          awslogs-region = "ap-south-1"

          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_security_group" "alb" {

  name   = "${var.environment}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {

  name   = "${var.environment}-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      aws_security_group.alb.id
    ]
  }

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_lb" "this" {

  name = "${var.environment}-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = var.public_subnet_ids
}

 resource "aws_lb_target_group" "app" {

  name = "${var.environment}-tg"

  port = 80

  protocol = "HTTP"

  target_type = "ip"

  vpc_id = var.vpc_id

  health_check {

    path = "/"

    protocol = "HTTP"

    matcher = "200"
  }
}

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.this.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_ecs_service" "app" {

  name = "${var.environment}-service"

  cluster = aws_ecs_cluster.this.id

  task_definition = aws_ecs_task_definition.app.arn

  desired_count = 1

  launch_type = "FARGATE"

  network_configuration {

    subnets = var.private_subnet_ids

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = false
  }

  load_balancer {

    target_group_arn = aws_lb_target_group.app.arn

    container_name = "nginx"

    container_port = 80
  }

  depends_on = [
    aws_lb_listener.http
  ]
}