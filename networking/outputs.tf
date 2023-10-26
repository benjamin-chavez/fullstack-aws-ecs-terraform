# networking/outputs.tf

# VPC
output "audio_archive_vpc_id" {
  description = "The ID of the audio archive VPC"
  value       = aws_vpc.audio_archive_vpc.id
}

# SUBNETS
output "audio_archive_public_subnet_id" {
  description = "The ID of the audio archive public subnet"
  value       = aws_subnet.public_subnet.id
}

output "audio_archive_private_subnet_id" {
  description = "The ID of the audio archive private subnet"
  value       = aws_subnet.private_subnet.id
}

# SECURITY GROUPS
