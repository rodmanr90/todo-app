output "ec2_public_ip" {
  description = "Public IP of the MongoDB EC2 instance"
  value       = aws_instance.mongo.public_ip
}

output "s3_bucket_url" {
  description = "S3 bucket URL for backups"
  value       = "https://${aws_s3_bucket.mongo_backups.bucket}.s3.amazonaws.com"
}
