resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-${local.service_name}"

  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT"
  ]

  tags = {
    Name = "${local.name_prefix}-${local.service_name}"
  }
}

resource "aws_ecs_task_definition" "this" {
  family = "${local.name_prefix}-${local.service_name}"

  task_role_arn = aws_iam_role.ecs_task.arn

  network_mode = "awsvpc"

  requires_compatibilities = [
    "FARGATE",
  ]

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  memory = "512"
  cpu    = "256"

  container_definitions = jsonencode(
    [
      {
        name  = "web"
        image = "${data.terraform_remote_state.ecr.outputs.web}:latest"

        portMappings = [
          {
            containerPort = 80
            protocol      = "tcp"
          }
        ]

        environment = []
        secrets     = []

        dependsOn = [
          {
            containerName = "php"
            condition     = "START"
          }
        ]

        mountPoints = [
          {
            containerPath = "/var/run/php-fpm"
            sourceVolume  = "php-fpm-socket"
          }
        ]

        # ログ
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/${local.name_prefix}-${(local.service_name)}/nginx"
            awslogs-region        = data.aws_region.current.id
            awslogs-stream-prefix = "ecs"
          }
        }

      },
      {
        name  = "php"
        image = "${data.terraform_remote_state.ecr.outputs.php}:latest"

        portMappings = []

        environment = []
        secrets = [
          {
            name      = "APP_KEY"
            valueFrom = "/${local.system_name}/${local.env_name}/${local.service_name}/APP_KEY"
          },
          {
            name      = "DB_HOST"
            valueFrom = "/${local.system_name}/${local.env_name}/${local.service_name}/DB_HOST"
          },
          {
            name      = "DB_PORT"
            valueFrom = "/${local.system_name}/${local.env_name}/${local.service_name}/DB_PORT"
          },
          {
            name      = "DB_DATABASE"
            valueFrom = "/${local.system_name}/${local.env_name}/${local.service_name}/DB_DATABASE"
          },
          {
            name      = "DB_USERNAME"
            valueFrom = "/${local.system_name}/${local.env_name}/${local.service_name}/DB_USERNAME"
          },
          {
            name      = "DB_PASSWORD"
            valueFrom = "/${local.system_name}/${local.env_name}/${local.service_name}/DB_PASSWORD"
          }
        ]

        dependsOn = [
          {
            containerName = "db"
            condition     = "START"
          }
        ]

        mountPoints = [
          {
            containerPath = "/var/run/php-fpm"
            sourceVolume  = "php-fpm-socket"
          }
        ]

        # ログ
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/${local.name_prefix}-${(local.service_name)}/php"
            awslogs-region        = data.aws_region.current.id
            awslogs-stream-prefix = "ecs"
          }
        }

      },
      {
        name  = "db"
        image = "${data.terraform_remote_state.ecr.outputs.db}:latest"

        portMappings = [
          {
            containerPort = 3306
            protocol      = "tcp"
          }
        ]

        environment = [
          {
            name  = "MYSQL_DATABASE"
            value = "laravel"
          },
          {
            name  = "MYSQL_USER"
            value = "dbuser"
          },
          {
            name  = "MYSQL_PASSWORD"
            value = "dbuserpassword"
          },
          {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "password"
          }
        ]

        secrets = []

        mountPoints = []

      },
    ]
  )

  volume {
    name = "php-fpm-socket"
  }

  tags = {
    Name = "${local.name_prefix}-${local.service_name}"
  }
}

resource "aws_ecs_service" "this" {
  name = "${local.name_prefix}-${local.service_name}"

  cluster = aws_ecs_cluster.this.arn

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 1
  }

  platform_version = "1.4.0"

  task_definition = aws_ecs_task_definition.this.arn

  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  # ALBとWEBコンテナを紐つけ
  load_balancer {
    container_name   = "web"
    container_port   = 80
    target_group_arn = data.terraform_remote_state.route.outputs.lb_target_group_shop_arn
  }

  health_check_grace_period_seconds = 3600

  network_configuration {
    assign_public_ip = false
    security_groups = [
      data.terraform_remote_state.network.outputs.security_group_vpc_id
    ]
    subnets = [
      for s in data.terraform_remote_state.network.outputs.subnet_private : s.id
    ]
  }

  enable_execute_command = true

  tags = {
    Name = "${local.name_prefix}-${local.service_name}"
  }
}