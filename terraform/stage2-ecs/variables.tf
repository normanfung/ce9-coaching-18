variable "aws_region" {
  default = "us-east-1"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "s3_app_image" {
  type = string
}

variable "sqs_app_image" {
  type = string
}
