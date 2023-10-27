# main.tf

/*===========================
          Root file
============================*/

# ------- Providers -------
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region

  # provider level tags - yet inconsistent when executing
  # default_tags {
  #   tags = {
  #     Created_by = "Terraform"
  #     Project    = "AWS_demo_fullstack_devops"
  #   }
  # }
}

# ------- Random numbers intended to be used as unique identifiers for resources -------
# resource "random_id" "RANDOM_ID" {
#   byte_length = "2"
# }

# ------- Account ID -------
data "aws_caller_identity" "id_current_account" {}

# ------- Networking -------
module "networking" {
  source = "./modules/networking"
  cidr   = ["10.120.0.0/16"]
  name   = var.environment_name
}

# ------- Creating Target Group for the server ALB blue environment -------
module "target_group_server" {
  source              = "./modules/alb"
  create_target_group = true
  name                = "tg-${var.environment_name}-server"
  port                = 80
  protocol            = "HTTP"
  vpc                 = module.networking.aws_vpc
  tg_type             = "ip"
  health_check_path   = "/api"
  health_check_port   = var.port_app_server
}

# ------- Creating Target Group for the client ALB blue environment -------
module "target_group_client" {
  source              = "./modules/alb"
  create_target_group = true
  name                = "tg-${var.environment_name}-client"
  port                = 80
  protocol            = "HTTP"
  vpc                 = module.networking.aws_vpc
  tg_type             = "ip"
  health_check_path   = "/"
  health_check_port   = var.port_app_client
}

# ------- Creating Security Group for the client ALB -------
module "security_group_alb_client" {
  source              = "./modules/security_groups"
  name                = "alb-${var.environment_name}-client"
  description         = "Controls access to the client ALB"
  vpc_id              = module.networking.aws_vpc
  cidr_blocks_ingress = ["0.0.0.0/0"]
  ingress_port        = 80
}

# ------- Creating Security Group for the server ALB -------
module "security_group_alb_server" {
  source              = "./modules/security_groups"
  name                = "alb-${var.environment_name}-server"
  description         = "Controls access to the server ALB"
  vpc_id              = module.networking.aws_vpc
  cidr_blocks_ingress = ["0.0.0.0/0"]
  ingress_port        = 80
}

# ------- Creating Client Application ALB -------
module "alb_client" {
  source         = "./modules/alb"
  create_alb     = true
  name           = "${var.environment_name}-client"
  subnets        = [module.networking.public_subnets[0], module.networking.public_subnets[1]]
  security_group = module.security_group_alb_client.sg_id
  target_group   = module.target_group_client.arn_tg
}

# ------- Creating Server Application ALB -------
module "alb_server" {
  source         = "./modules/alb"
  create_alb     = true
  name           = "${var.environment_name}-server"
  subnets        = [module.networking.public_subnets[0], module.networking.public_subnets[1]]
  security_group = module.security_group_alb_server.sg_id
  target_group   = module.target_group_server.arn_tg
}

# ------- ECS Role -------
module "ecs_role" {
  source             = "./modules/iam"
  create_ecs_role    = true
  name               = var.iam_role_name["ecs"]
  name_ecs_task_role = var.iam_role_name["ecs_task_role"]
  # dynamodb_table     = [module.dynamodb_table.dynamodb_table_arn]
}


# ------- Creating a IAM Policy for role -------
module "ecs_role_policy" {
  source        = "./modules/iam"
  name          = "ecs-ecr-${var.environment_name}"
  create_policy = true
  attach_to     = module.ecs_role.name_role
}

###################################################################################

# ------- Creating server ECR Repository to store Docker Images -------
module "ecr_server" {
  source = "./modules/ecr"
  name   = "repo-server"
}

# ------- Creating client ECR Repository to store Docker Images -------
module "ecr_client" {
  source = "./modules/ecr"
  name   = "repo-client"
}


# ------- Creating ECS Task Definition for the server -------
module "ecs_task_definition_server" {
  source             = "./modules/ecs/task-definition"
  name               = "${var.environment_name}-server"
  container_name     = var.container_name["server"]
  execution_role_arn = module.ecs_role.arn_role
  task_role_arn      = module.ecs_role.arn_role_ecs_task_role
  cpu                = 256
  memory             = "512"
  docker_repo        = module.ecr_server.ecr_repository_url
  region             = var.aws_region
  container_port     = var.port_app_server
}

# ------- Creating ECS Task Definition for the client -------
module "ecs_task_definition_client" {
  source             = "./modules/ecs/task-definition"
  name               = "${var.environment_name}-client"
  container_name     = var.container_name["client"]
  execution_role_arn = module.ecs_role.arn_role
  task_role_arn      = module.ecs_role.arn_role_ecs_task_role
  cpu                = 256
  memory             = "512"
  docker_repo        = module.ecr_client.ecr_repository_url
  region             = var.aws_region
  container_port     = var.port_app_client
}

# ------- Creating a server Security Group for ECS TASKS -------
module "security_group_ecs_task_server" {
  source          = "./modules/security_groups"
  name            = "ecs-task-${var.environment_name}-server"
  description     = "Controls access to the server ECS task"
  vpc_id          = module.networking.aws_vpc
  ingress_port    = var.port_app_server
  security_groups = [module.security_group_alb_server.sg_id]
}
# ------- Creating a client Security Group for ECS TASKS -------
module "security_group_ecs_task_client" {
  source          = "./modules/security_groups"
  name            = "ecs-task-${var.environment_name}-client"
  description     = "Controls access to the client ECS task"
  vpc_id          = module.networking.aws_vpc
  ingress_port    = var.port_app_client
  security_groups = [module.security_group_alb_client.sg_id]
}

# ------- Creating ECS Cluster -------
module "ecs_cluster" {
  source = "./modules/ecs/cluster"
  name   = var.environment_name
}


# ------- Creating ECS Service server -------
module "ecs_service_server" {
  depends_on          = [module.alb_server]
  source              = "./modules/ecs/service"
  name                = "${var.environment_name}-server"
  desired_tasks       = 1
  arn_security_group  = module.security_group_ecs_task_server.sg_id
  ecs_cluster_id      = module.ecs_cluster.ecs_cluster_id
  arn_target_group    = module.target_group_server.arn_tg
  arn_task_definition = module.ecs_task_definition_server.arn_task_definition
  subnets_id          = [module.networking.private_subnets_server[0], module.networking.private_subnets_server[1]]
  container_port      = var.port_app_server
  container_name      = var.container_name["server"]
}

# ------- Creating ECS Service client -------
module "ecs_service_client" {
  depends_on          = [module.alb_client]
  source              = "./modules/ecs/service"
  name                = "${var.environment_name}-client"
  desired_tasks       = 1
  arn_security_group  = module.security_group_ecs_task_client.sg_id
  ecs_cluster_id      = module.ecs_cluster.ecs_cluster_id
  arn_target_group    = module.target_group_client.arn_tg
  arn_task_definition = module.ecs_task_definition_client.arn_task_definition
  subnets_id          = [module.networking.private_subnets_client[0], module.networking.private_subnets_client[1]]
  container_port      = var.port_app_client
  container_name      = var.container_name["client"]
}

# ------- Creating ECS Autoscaling policies for the server application -------

# ------- Creating ECS Autoscaling policies for the client application -------

# ------- CodePipeline -------

# ------- Creating Bucket to store CodePipeline artifacts -------

# ------- Creating IAM roles used during the pipeline excecution -------
