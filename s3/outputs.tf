output "s3_bucket_arn" {
  value       = "aws_s3_bucket.genesis_terraform_state_bucket.arn"
  description = "The ARN for the s3 bucket"
}

output "dynamodb_table_name" {
  value       = "genesis-terraform-dynamodb-locks-table.name"
  description = "The name of the dynamodb table"
}
