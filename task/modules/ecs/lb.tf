# resources needed to enble https access to the hello-world app are commented out below
# this is because aws charges $400+ to run their certificate authority

data "aws_elb_service_account" "current" {}

# security groups
resource "aws_security_group" "alb" {
  name   = "devops-tech-task-sg-alb"
  vpc_id = var.vpc

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  #    ingress {
  #    protocol    = "tcp"
  #    from_port   = 443
  #    to_port     = 443
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    role = "ecs"
    name = "devops-tech-task"
  }
}

resource "aws_security_group" "ecs_tasks" {
  name   = "devops-tech-task-sg-task"
  vpc_id = var.vpc

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    role = "ecs"
    name = "devops-tech-task"
  }
}

# alb load balancer
resource "aws_lb" "self" {
  name                       = "devops-tech-task-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.public_subnets
  enable_deletion_protection = false
  drop_invalid_header_fields = true

  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.alb.bucket
  }

  tags = {
    role = "ecs"
    name = "devops-tech-task"
  }
}

resource "aws_alb_target_group" "self" {
  name        = "devops-tech-task-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    path                = "/"
    unhealthy_threshold = "3"
  }

  tags = {
    role = "ecs"
    name = "devops-tech-task"
  }
}

# if you are uncommenting the code to enable https access, comment out this http aws_alb_listenenr
# and uncomment the http aws_alb_listener below
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.self.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.self.id
    type             = "forward"
  }

  tags = {
    role = "ecs"
    name = "devops-tech-task"
  }
}

#resource "aws_alb_listener" "http" {
#  load_balancer_arn = aws_lb.self.id
#  port              = 80
#  protocol          = "HTTP"

#  default_action {
#    type = "redirect"

#    redirect {
#      port        = 443
#      protocol    = "HTTPS"
#      status_code = "HTTP_301"
#    }
#  }

#  tags = {
#    role = "ecs"
#    name = "devops-tech-task"
#  }
#}

#resource "aws_alb_listener" "https" {
#  load_balancer_arn = aws_lb.self.id
#  port              = 443
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = aws_acm_certificate.fake.arn

#  default_action {
#    target_group_arn = aws_alb_target_group.self.id
#    type             = "forward"
#  }

#  tags = {
#    role = "ecs"
#    name = "devops-tech-task"
#  }
#}

# alb s3 bucket for logs
resource "aws_s3_bucket" "alb" {
  bucket        = "devops-tech-task-alb-access-logs"
  force_destroy = true

  tags = {
    role = "ecs"
    name = "devops-tech-task"
  }
}

resource "aws_s3_bucket_acl" "alb" {
  bucket = aws_s3_bucket.alb.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "alb" {
  bucket = aws_s3_bucket.alb.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "alb" {
  bucket = aws_s3_bucket.alb.id

  rule {
    id = "cleanup"
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
    expiration {
      days = 1
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "lb_access_logs" {
  bucket = aws_s3_bucket.alb.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow"
        Action    = ["s3:PutObject"]
        Resource  = ["${aws_s3_bucket.alb.arn}", "${aws_s3_bucket.alb.arn}/*"]
        Principal = { "AWS" : "${data.aws_elb_service_account.current.arn}" }
    }]
  })
}
