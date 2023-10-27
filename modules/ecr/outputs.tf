# modules/ecr/outputs.tf

output "ecr_repository_url" {
  value = aws_ecr_repository.ecr_repository.repository_url
}

output "ecr_repository_arn" {
  value = aws_ecr_repository.ecr_repository.arn
}

# output "client_repo_url" {
#   description = "ECR repository URL for the client service."
#   value       = aws_ecr_repository.client.repository_url
# }

# output "server_repo_url" {
#   description = "ECR repository URL for the server service."
#   value       = aws_ecr_repository.server.repository_url
# }
