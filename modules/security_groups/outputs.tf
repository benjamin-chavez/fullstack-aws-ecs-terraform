# modules/acm/outputs.tf

output "sg_id" {
  value = aws_security_group.sg.id
}

# resource "aws_security_group" "ecs_sg" {
#   name        = "audio-archive-ecs-sg"
#   description = "Security Group for Audio Archive ECS Services"
#   vpc_id      = aws_vpc.audio_archive_vpc.id

#   ingress {
#     from_port       = 3000
#     to_port         = 3000
#     protocol        = "tcp"
#     security_groups = [aws_security_group.audio_archive_lb_sg.id]
#   }

#   ingress {
#     from_port       = 5000
#     to_port         = 5000
#     protocol        = "tcp"
#     security_groups = [aws_security_group.audio_archive_lb_sg.id]
#   }
# }
