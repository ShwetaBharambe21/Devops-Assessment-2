output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "task_definition" {
  value = aws_ecs_task_definition.app.arn
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}