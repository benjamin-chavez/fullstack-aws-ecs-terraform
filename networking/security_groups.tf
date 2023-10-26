# networking/security_groups.tf


resource "aws_security_group" "audio_archive_sg" {
  name        = "audio-archive-sg"
  description = "Audio Archive Security Group"
  vpc_id      = aws_vpc.audio_archive_vpc.id

  # Inbound HTTP Traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTPS Traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "audio-archive-sg"
  }
}

resource "aws_security_group" "audio_archive_lb_sg" {
  name        = "audio-archive-lb-sg"
  description = "Security Group for Audio Archive Load Balancers"
  vpc_id      = aws_vpc.audio_archive_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "audio_archive_ecs_sg" {
  name        = "audio-archive-ecs-sg"
  description = "Security Group for Audio Archive ECS Services"
  vpc_id      = aws_vpc.audio_archive_vpc.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.audio_archive_lb_sg.id]
  }

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.audio_archive_lb_sg.id]
  }
}

resource "aws_security_group" "audio_archive_rds_sg" {
  name        = "audio-archive-rds-sg"
  description = "Security Group for Audio Archive RDS Instance"
  vpc_id      = aws_vpc.audio_archive_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.audio_archive_ecs_sg.id]
  }
}







////////////
# resource "aws_security_group" "auth0_security_group" {
#   name        = "auth0-security-group"
#   description = "auth0-security-group"
#   vpc_id      = "vpc-0edd11663202eaf4f"

#   ingress {
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 5000
#     to_port     = 5000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 3000
#     to_port     = 3000
#     protocol    = "tcp"
#     security_groups = [aws_security_group.audio_archive_lb_sg.id]
#   }

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "auth0-vpc-vpc"
#   }
# }

# resource "aws_security_group" "audio_archive_lb_sg" {
#   name        = "AudioArchiveLoadBalancer-SecurityGroup"
#   description = "Audio Archive Load Balancer - Security Group"
#   vpc_id      = "vpc-0edd11663202eaf4f"

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "AudioArchiveLoadBalancer-SecurityGroup"
#   }
# }

# resource "aws_security_group" "audio_archive_sg" {
#   name        = "audioarchive-securityGroup"
#   description = "audioarchive-securityGroup"
#   vpc_id      = "vpc-0edd11663202eaf4f"

#   ingress {
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "audioarchive-securityGroup"
#   }
# }

# resource "aws_security_group" "audio_archive_server_lb_sg" {
#   name        = "AudioArchive-ServerLB-SG"
#   description = "AudioArchive-ServerLB-SG"
#   vpc_id      = "vpc-0edd11663202eaf4f"

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     security_groups = [aws_security_group.default_sg.id]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     security_groups = [aws_security_group.default_sg.id]
#   }

#   egress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "AudioArchive-ServerLB-SG"
#   }
# }

# resource "aws_security_group" "default_sg" {
#   name        = "default"
#   description = "default VPC security group"
#   vpc_id      = "vpc-0edd11663202eaf4f"

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     security_groups = [aws_security_group.audio_archive_lb_sg.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "default"
#   }
# }
