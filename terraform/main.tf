provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "main-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  tags = { Name = "public-subnet" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "main-igw" }
}

resource "aws_security_group" "mongo_sg" {
  name        = "mongo-ec2-sg"
  description = "Allow SSH and MongoDB access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow MongoDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict later to EKS node SG if needed
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "mongo-sg" }
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "mongo-s3-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "mongo" {
  ami                         = var.ec2_ami
  instance_type               = "t2.small"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.mongo_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  key_name                    = var.key_name

  tags = { Name = "MongoDB-VM-TF" }
}

resource "aws_s3_bucket" "mongo_backups" {
  bucket = var.s3_bucket_name

  tags = { Name = "Mongo Backups" }
}

resource "aws_s3_bucket_policy" "public_readable" {
  bucket = aws_s3_bucket.mongo_backups.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = ["s3:GetObject", "s3:ListBucket"]
      Resource  = [
        "arn:aws:s3:::${var.s3_bucket_name}",
        "arn:aws:s3:::${var.s3_bucket_name}/*"
      ]
    }]
  })
}
