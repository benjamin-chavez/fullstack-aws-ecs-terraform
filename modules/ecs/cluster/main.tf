# modules/ecs/cluster/main.tf

/*=============================
        AWS ECS Cluster
===============================*/

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "Cluster-${var.name}"
}
