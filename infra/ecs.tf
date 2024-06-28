module "ecs" {
  source  = "zkfmapf123/ecs-fargate/lee"
  prefix  = "donggyu"
  version = "1.0.6"

  providers = {
    aws = aws.main
  }

  vpc_attr = {
    vpc_id         = local.vpc_id
    alb_subnet_ids = local.subnet_ids
  }

  lb_attr = {
    internal             = false
    deregistration_delay = 60
  }

  lb_health = {
    path                = "/health"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }

  ecs_extends_policy = {
    "Action" : [
      "sqs:*"
    ],
    "Effect" : "Allow",
    "Resource" : ["arn:aws:sqs:ap-northeast-2:${data.aws_caller_identity.blue_currnt.id}:${aws_sqs_queue.eda-sqs.name}"]
  }


  is_create_cluster = {
    is_enable           = true
    exists_cluster_name = ""
  }

  is_create_ecr = {
    is_enable       = false
    exists_ecr_name = ""
  }

  ecs_attr = {
    port          = 3000
    cpu           = 256
    memory        = 512
    desired_count = 1
    subnet_ids    = local.private_subnet_ids
    is_public     = true
  }

  task_def = [{
    name      = "ecs-server-container"
    image     = "zkfmapf123/donggyu-friends:2.0"
    cpu       = 256
    memory    = 512
    essential = true,

    environment = [
      {
        name  = "PORT",
        value = "3000"
      }
    ],
    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      },
    ],
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "server-container"
        awslogs-create-group  = "true"
        awslogs-region        = "ap-northeast-2"
        awslogs-stream-prefix = "ecs"
      }
    }
  }]
}
