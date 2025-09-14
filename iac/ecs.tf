resource "aws_ecs_cluster" "intens_praksa" {
  name = "intens-praksa-${var.env}-cluster"  

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "intens_praksa" {
  family = "intens-praksa${var.env}-task-def"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu       = 1024
  memory    = 6144
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = <<DEFINITION
[
  {
    "name": "intens-praksa-app",
    "image": "${aws_ecr_repository.intens_praksa.repository_url}:latest",
    "essential": true,
    "portMappings": [
      {    
        "containerPort": 8080,
        "hostPort": 8080,
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "intens-praksa-${var.env}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "intens_praksa" {
  name            = "intens-praksa-${var.env}-service"
  cluster         = aws_ecs_cluster.intens_praksa.name
  task_definition = aws_ecs_task_definition.intens_praksa.arn
  desired_count   = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  depends_on      = [aws_alb_listener.http, aws_alb_listener.https]

  network_configuration {
   security_groups  = [aws_security_group.container.id]
   subnets          = [var.priv_sub]
   assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "intens-praksa-${var.env}"
    container_port   = 8080
  }
}

# Load balancer
resource "aws_lb" "main" {
  name               = "intens-praksa-${var.env}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [var.pub_sub]
 
  enable_deletion_protection = false
}

# Target group
resource "aws_lb_target_group" "main" {
  name        = "intens-praksa-${var.env}"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    unhealthy_threshold = 10
    healthy_threshold   = 2   
    timeout             = 5    
    interval            = 30    
  }
  lifecycle {
      create_before_destroy = true
      ignore_changes        = [name]
    }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"
 
  default_action {
   type = "redirect"
 
   redirect {
     port        = 443
     protocol    = "HTTPS"
     status_code = "HTTP_301"
   }
  }
}
 
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.main.id
  port              = 443
  protocol          = "HTTPS"
 
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn
 
  default_action {
    target_group_arn = aws_lb_target_group.main.id
    type             = "forward"
  }
}


# ECS Role
resource "aws_iam_role" "ecs_task_role" {
  name = "intens-praksa-${var.env}-task-role"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "intens-praksa-${var.env}-execution-role"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_security_group" "alb" {
  name = "intens-praksa-sg-alb"
  description = "alb"
  vpc_id      = var.vpc_id

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      description = "Security Group for deployment"
      self = false
    }
  ]

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
    security_groups = []
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = []
  }
}



resource "aws_security_group" "container" {
  name = "intens-praksa-${var.env}"
  description = "container"
  vpc_id      = var.vpc_id

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      description = "Security Group for deployment"
      self = false
    }
  ]

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = []
    security_groups = [aws_security_group.alb.id]
  }

}