/*
    These routines will stop and start the instance on a specific schedule.
    It requires an IAM role that can be assumed by EventBridge.
*/

resource "aws_iam_role" "instance_scheduler" {
  name = "instance_scheduler-${random_string.stack_id.result}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "scheduler.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

data "aws_iam_policy_document" "start_stop_policy" {
  statement {
    actions   = ["ec2:StartInstances", "ec2:StopInstances"]
    resources = [aws_instance.grafana.arn]
  }
}

resource "aws_iam_role_policy" "start_stop_policy" {
  name   = "start_stop_policy"
  role   = aws_iam_role.instance_scheduler.name
  policy = data.aws_iam_policy_document.start_stop_policy.json
}

resource "aws_scheduler_schedule" "stop_grafana_schedule" {
  name        = "stop-grafana-schedule"
  group_name  = "default"
  description = "Stops the Grafana instance at 10:30 PM and 12:30 PM UTC"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(30 12,22 * * ? *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.instance_scheduler.arn
    input = jsonencode({
      InstanceIds = [aws_instance.grafana.id]
    })
  }
}

resource "aws_scheduler_schedule" "start_grafana_schedule" {
  name        = "start-grafana-schedule"
  group_name  = "default"
  description = "Starts the Grafana instance at 9:30 AM and 5:30 PM UTC"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(30 9,17 * * ? *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.instance_scheduler.arn
    input = jsonencode({
      InstanceIds = [aws_instance.grafana.id]
    })
  }
}
