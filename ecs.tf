# ecs.tf

# ECS Cluster
resource "aws_ecs_cluster" "audio_archive_cluster" {
  name = "audio-archive-cluster"
}

# Next.js Client Task Definition
resource "aws_ecs_task_definition" "audio_archive_client_task" {
  family                   = "audio-archive-client"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::369579651631:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::369579651631:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "audio-archive-client-container",
      image     = "${aws_ecr_repository.audio_archive_nextjs_client.repository_url}:latest",
      cpu       = 0,
      essential = true,
      portMappings = [
        {
          containerPort = 3000,
          hostPort      = 3000,
        }
      ],
      "environment" : [
        {
          "name" : "AUTH0_CLIENT_SECRET",
          "value" : "xZbJE62MnzdaZOhCk4RbmCsoCiOyWyHHTLqCkr-K9_EdqI6TTrkaOTLsYN-6IkyG"
        },
        {
          "name" : "AUTH0_CLIENT_ID",
          "value" : "wnmr7FUFftunKztRN9yP89VET8xo0rem"
        },
        {
          "name" : "AUTH0_SCOPE",
          "value" : "openid profile"
        },
        {
          "name" : "AUTH0_ISSUER_BASE_URL",
          "value" : "https://dev-fe4e0mvsji0bzexh.us.auth0.com"
        },
        {
          "name" : "AUTH0_BASE_URL",
          "value" : "http://development.benchavez.xyz/"
        },
        {
          "name" : "AUTH0_AUDIENCE",
          "value" : ""
        },
        {
          "name" : "AUTH0_SECRET",
          "value" : "replace-with-your-own-secret-generated-with-openssl"
        }
      ],
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          "awslogs-create-group"  = "true",
          "awslogs-group"         = "/ecs/audio_archive_client",
          "awslogs-region"        = "us-east-1",
          "awslogs-stream-prefix" = "ecs"
        },
        "secretOptions" : []
      }
    }
  ])
}

# Next.js Client Service Definition
resource "aws_ecs_service" "audio_archive_client_service" {
  name            = "audio-archive-client-service"
  cluster         = aws_ecs_cluster.audio_archive_cluster.id
  task_definition = aws_ecs_task_definition.audio_archive_client_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  # iam_role        = aws_iam_role.foo.arn
  # depends_on      = [aws_iam_role_policy.foo]
  force_new_deployment = true

  triggers = {
    redeployment = timestamp()
  }

  network_configuration {
    subnets = [aws_subnet.private_subnet.id] # Reference the private subnet
    # security_groups  = [data.aws_security_group.default_sg.id]
    # assign_public_ip = true
    security_groups  = [aws_security_group.audio_archive_ecs_sg.id]
    assign_public_ip = false

  }

  load_balancer {
    target_group_arn = aws_lb_target_group.audio_archive_client_lb_tg.arn
    container_name   = "audio-archive-client-container"
    container_port   = 3000
  }
}


# Express.js Server Task Definition
resource "aws_ecs_task_definition" "audio_archive_server_task" {
  family                   = "audio-archive-server"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"
  execution_role_arn       = "arn:aws:iam::369579651631:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::369579651631:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "audio-archive-server-container",
      image     = "${aws_ecr_repository.audio_archive_express_server.repository_url}:latest",
      cpu       = 0,
      essential = true,
      "portMappings" : [
        {
          "name" : "server-5000-tcp",
          "containerPort" : 5000,
          "hostPort" : 5000,
          "protocol" : "tcp",
        }
      ],
      "environment" : [
        {
          "name" : "DATABASE_PORT",
          "value" : "5432"
        },
        {
          "name" : "DATABASE_NAME",
          "value" : "audio_archive_aws_development"
        },
        {
          "name" : "DATABASE_HOST",
          "value" : "audioarchive.cjymtqoepcyq.us-east-1.rds.amazonaws.com"
        },
        {
          "name" : "DATABASE_PASSWORD",
          "value" : "x3HaD9fNAB6qCQe9K9VW"
        },
        {
          "name" : "DATABASE_USER",
          "value" : "postgres"
        }
      ],
    }
  ])

}


# Express.js Server Service Definition
resource "aws_ecs_service" "audio_archive_server_service" {
  name            = "audio-archive-server-service"
  cluster         = aws_ecs_cluster.audio_archive_cluster.id
  task_definition = aws_ecs_task_definition.audio_archive_server_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  # iam_role        = aws_iam_role.foo.arn
  # depends_on      = [aws_iam_role_policy.foo]
  force_new_deployment = true

  triggers = {
    redeployment = timestamp()
  }

  network_configuration {
    subnets = [
      aws_subnet.private_subnet.id
    ]
    # security_groups  = [data.aws_security_group.default_sg.id]
    # assign_public_ip = true
    security_groups  = [aws_security_group.audio_archive_ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.audio_archive_server_lb_tg.arn
    container_name   = "audio-archive-server-container"
    container_port   = 5000
  }
}
