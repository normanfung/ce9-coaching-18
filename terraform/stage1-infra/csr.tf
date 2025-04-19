resource "aws_ecr_repository" "s3_app_repo" {
  name                 = "${local.prefix}-csr-s3-app"
  image_tag_mutability = "MUTABLE" # or "IMMUTABLE" for stricter image control
  encryption_configuration {
    encryption_type = "AES256"
  }
  force_delete = true
}

resource "aws_ecr_repository" "sqs_app_repo" {
  name                 = "${local.prefix}-csr-sqs-app"
  image_tag_mutability = "MUTABLE" # or "IMMUTABLE" for stricter image control
  encryption_configuration {
    encryption_type = "AES256"
  }
  force_delete = true
}

resource "aws_ecr_repository_policy" "csr_policy_s3" {
  repository = aws_ecr_repository.s3_app_repo.name

  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid    = "AllowPushPull"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}

resource "aws_ecr_repository_policy" "csr_policy_sqs" {
  repository = aws_ecr_repository.sqs_app_repo.name

  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid    = "AllowPushPull"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}
