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
  value       = aws_ecr_repository.sqs_app_repo.name
}

output "sqs_ecr_repo_url" {
  description = "The full URI of the SQS ECR repository"
  value       = aws_ecr_repository.sqs_app_repo.repository_url
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.s3.bucket

}


output "s3_bucket_arn" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.s3.arn

}

output "sqs_queue_name" {
  description = "The name of the SQS queue"
  value       = aws_sqs_queue.sqs_queue.name
}

output "sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.sqs_queue.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.sqs_queue.url
}

