output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "s3_ecr_repo_name" {
  description = "The name of the S3 ECR repository"
  value       = aws_ecr_repository.s3_app_repo.name
}

output "s3_ecr_repo_url" {
  description = "The full URI of the S3 ECR repository"
  value       = aws_ecr_repository.s3_app_repo.repository_url
}

output "sqs_ecr_repo_name" {
  description = "The name of the SQS ECR repository"
  value       = aws_ecr_repository.s3_app_repo.name
}

output "sqs_ecr_repo_url" {
  description = "The full URI of the SQS ECR repository"
  value       = aws_ecr_repository.s3_app_repo.repository_url
}

