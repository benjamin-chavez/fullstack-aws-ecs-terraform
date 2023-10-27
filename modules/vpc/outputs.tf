# modules/vpc/outputs.tf

output "audio_archive_vpc_id" {
  description = "The ID of the Audio Archive VPC."
  value       = aws_vpc.audio_archive_vpc.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet."
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet."
  value       = aws_subnet.private_subnet.id
}
