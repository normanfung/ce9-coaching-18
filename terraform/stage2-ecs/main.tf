locals {
  prefix = "norman-ce9"
}

provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "sctp-ce9-tfstate"
    key    = "norman-ce9-module3-coaching2-stage2-infra.tfstate" # Replace the value of key to <your suggested name>.tfstat   
    region = "us-east-1"
  }
}

data "terraform_remote_state" "stage1" {
  backend = "s3"
  config = {
    bucket = "sctp-ce9-tfstate"
    key    = "norman-ce9-module3-coaching2-stage1-infra.tfstate" # Replace the value of key to <your suggested name>.tfstat   
    region = "us-east-1"
  }
}


# Security Group
resource "aws_security_group" "ecs" {
  name   = "ecs-fargate-sg"
  vpc_id = data.terraform_remote_state.stage1.outputs.vpc_id

  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5002
    to_port     = 5002
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

# # ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-fargate-cluster"
}

# IAM Role for Fargate
resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.prefix}-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_app_policy" {
  name = "${local.prefix}-ecs-app-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ],
        Resource = "${data.terraform_remote_state.stage1.outputs.s3_bucket_name}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = data.terraform_remote_state.stage1.outputs.sqs_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_app_policy_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_app_policy.arn
}

resource "aws_ecs_task_definition" "multi_app_task" {
  family                   = "multi-app-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "s3-app"
      image = var.s3_app_image
      portMappings = [
        {
          containerPort = 5001
        }
      ]
      essential = true
      environment = [
        {
          name  = "AWS_REGION"
          value = "us-east-1"
        },
        {
          name  = "BUCKET_NAME"
          value = data.terraform_remote_state.stage1.outputs.s3_bucket_name
        }
      ]
    },
    {
      name  = "sqs-app"
      image = var.sqs_app_image
      portMappings = [
        {
          containerPort = 5002
        }
      ]
      essential = true
      environment = [
        {
          name  = "AWS_REGION"
          value = "us-east-1"
        },
        {
          name  = "QUEUE_NAME"
          value = data.terraform_remote_state.stage1.outputs.sqs_queue_name
        }
      ]
    }
  ])
}



#ECS Service
resource "aws_ecs_service" "multi_app_service" {
  name            = "multi-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.multi_app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.terraform_remote_state.stage1.outputs.public_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
}
