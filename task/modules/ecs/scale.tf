resource "aws_appautoscaling_target" "self" {
  max_capacity       = 10
  min_capacity       = 3
  resource_id        = "service/${aws_ecs_cluster.self.name}/${aws_ecs_service.self.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "devops-tech-task-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  treat_missing_data  = "notBreaching"
  threshold           = 50

  dimensions = {
    ClusterName = aws_ecs_cluster.self.name
    ServiceName = aws_ecs_service.self.name
  }

  alarm_actions = [aws_appautoscaling_policy.up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "devops-tech-task-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  treat_missing_data  = "notBreaching"
  threshold           = 10

  dimensions = {
    ClusterName = aws_ecs_cluster.self.name
    ServiceName = aws_ecs_service.self.name
  }

  alarm_actions = [aws_appautoscaling_policy.down.arn]
}

resource "aws_appautoscaling_policy" "up" {
  name               = "devops-tech-task-scale-up"
  service_namespace  = aws_appautoscaling_target.self.service_namespace
  resource_id        = aws_appautoscaling_target.self.resource_id
  scalable_dimension = aws_appautoscaling_target.self.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "down" {
  name               = "devops-tech-task-scale-down"
  service_namespace  = aws_appautoscaling_target.self.service_namespace
  resource_id        = aws_appautoscaling_target.self.resource_id
  scalable_dimension = aws_appautoscaling_target.self.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}
