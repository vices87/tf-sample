
#Fetch AMI 

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


# Create ECS Cluster

resource "aws_ecs_cluster" "cluster" {
  name = "ecs-${var.prefix}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


# Create Security Group for Front

resource "aws_security_group" "sg_asg" {
  name        = "${var.prefix}-sg"
  description = "Allow connection to ${var.prefix}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "sg_rule_asg" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_asg.id
}


# Create Launch Templates

resource "aws_launch_template" "launch_template" {
  name                   = "${var.prefix}-template"
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg_asg.id]

  user_data = filebase64("${var.user_data}")

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = var.subnet_id
  }

  iam_instance_profile {
    name = "${var.prefix}-instance-profile"
  }

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      delete_on_termination = true
      volume_size           = var.ebs_size
      volume_type           = var.ebs_type
    }
  }

}

# Create Auto Scaling Group

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.prefix}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_size
  health_check_grace_period = 300
  force_delete              = true
  vpc_zone_identifier       = [var.subnet_id]

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$latest"
  }
}

# Shutdown Schedule

resource "aws_autoscaling_schedule" "shutdown_schedule" {
  scheduled_action_name  = "shutdown-instances"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "0 22 * * ? *" # Shut down every day at 10:00 PM UTC
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# Startup Schedule

resource "aws_autoscaling_schedule" "startup_schedule" {
  scheduled_action_name  = "startup-instances"
  min_size               = 1
  max_size               = 5
  desired_capacity       = 1
  recurrence             = "0 8 * * ? *" # Start every day at 8:00 AM UTC
  autoscaling_group_name = aws_autoscaling_group.asg.name
}


# Cloudwatch Alarm

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "scale-out-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS" #AWS/EC2
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Scale out when CPU utilization is high"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
  dimensions = {
    # ServiceName = aws_ecs_service.example.name
   # ClusterName          = aws_ecs_cluster.cluster.name
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

# Scale out policy

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}