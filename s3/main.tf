resource "aws_s3_bucket" "genesis_terraform_state_bucket" {
  bucket = "genesis-terraform-state-bucket"
  lifecycle {
    prevent_destroy = false
  }
  versioning {
    enabled = true
  }
  #Enable serverside encryption(SSE)
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "genesis-terraform-dynamodb-locks" {
  name         = "genesis-terraform-dynamodb-locks-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "genesis-terraform-dynamodb-table-1"
    Environment = "production"
  }
}

terraform {
  backend "s3" {
    bucket         = "${genesis_terraform_state_bucket}"
    key            = "genesis/prod/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "${genesis-terraform-dynamodb-locks-table}"
    encrypt        = true
  }
}
