# lb.tf

# CLIENT LOAD BALANCER
resource "aws_lb" "audio_archive_client_lb" {
  name                             = "audio-archive-client-lb"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = ["sg-073bf3dd5533d592d"]
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  ip_address_type                  = "ipv4"
  subnets = [
    "subnet-0017ab5e561ceaece",
    "subnet-021282a66499e7d8a",
    "subnet-031df24201150cae7",
    "subnet-0c22499403b4d9731",
    "subnet-0d66c1359e04fab75",
    "subnet-0d9bd9d39707ee9fe"
  ]

  enable_http2 = true
}

resource "aws_lb_target_group" "audio_archive_client_lb_tg" {
  name     = "audio-archive-client-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = "vpc-0edd11663202eaf4f"
  # health_check {
  #   enabled             = true
  #   interval            = 30
  #   path                = "/"
  #   port                = "traffic-port"
  #   protocol            = "HTTP"
  #   timeout             = 5
  #   healthy_threshold   = 5
  #   unhealthy_threshold = 2
  #   matcher             = "200-399"
  # }
}

# HTTP Listener for the AudioArchive-LoadBalancer
resource "aws_lb_listener" "audio_archive_client_lb_http_listener" {
  load_balancer_arn = aws_lb.audio_archive_client_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}


# HTTPS Listener for the AudioArchive-LoadBalancer
resource "aws_lb_listener" "audio_archive_client_lb_https_listener" {
  load_balancer_arn = aws_lb.audio_archive_client_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:us-east-1:369579651631:certificate/48f3d47f-dfb1-4df6-9b92-47e1b94f1117"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.audio_archive_client_lb_tg.arn
  }
}


##########################################################################
# SERVER LOAD BALANCER
resource "aws_lb" "audio_archive_server_lb" {
  name               = "audio-archive-server-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    "sg-00a3fa487a7b2075e",
    "sg-073bf3dd5533d592d",
  "sg-0525a533954a60216"]
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  ip_address_type                  = "ipv4"
  subnets = [
    "subnet-0017ab5e561ceaece",
    "subnet-021282a66499e7d8a",
    "subnet-031df24201150cae7",
    "subnet-0c22499403b4d9731",
    "subnet-0d66c1359e04fab75",
    "subnet-0d9bd9d39707ee9fe"
  ]

  enable_http2 = true
}

resource "aws_lb_target_group" "audio_archive_server_lb_tg" {
  name     = "audio-archive-server-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0edd11663202eaf4f"
  health_check {
    enabled = true
    #   interval            = 30
    path = "/api"
    #   port                = "traffic-port"
    #   protocol            = "HTTP"
    #   timeout             = 5
    #   healthy_threshold   = 5
    #   unhealthy_threshold = 2
    #   matcher             = "200-399"
  }
}


# HTTP Listener for the AudioArchive-LoadBalancer
resource "aws_lb_listener" "audio_archive_server_lb_http_listener" {
  load_balancer_arn = aws_lb.audio_archive_server_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.audio_archive_server_lb_tg.arn
  }
}


# HTTPS Listener for the AudioArchive-LoadBalancer
resource "aws_lb_listener" "audio_archive_server_lb_https_listener" {
  load_balancer_arn = aws_lb.audio_archive_server_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:us-east-1:369579651631:certificate/48f3d47f-dfb1-4df6-9b92-47e1b94f1117"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.audio_archive_server_lb_tg.arn
  }
}
