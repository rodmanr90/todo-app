variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "S3 bucket for MongoDB backups"
  default     = "rod-mongo-bucket-tf"
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
}

variable "ec2_ami" {
  description = "AMI ID for EC2 instance"
  type        = string
}
