# modules/ecr/variables.tf

variable "name" {
  description = "The name of the ECR repository"
  type        = string
}

# variable "client_repo_name" {
#   description = "Name of the ECR repository for the frontend service."
#   type        = string
# }

# variable "server_repo_name" {
#   description = "Name of the ECR repository for the backend service."
#   type        = string
# }

# variable "client_lifecycle_policy_repo" {
#   description = "Name of the ECR repository to which the client lifecycle policy should be applied."
#   type        = string
#   default     = "" # Set a default to the client repo name or leave it empty to make it mandatory
# }

# variable "server_lifecycle_policy_repo" {
#   description = "Name of the ECR repository to which the server lifecycle policy should be applied."
#   type        = string
#   default     = "" # Set a default to the server repo name or leave it empty to make it mandatory
# }
