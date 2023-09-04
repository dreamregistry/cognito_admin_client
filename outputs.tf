output "USER_POOL_ID" {
  description = "The ID of the user pool"
  value       = var.cognito_user_pool_id
}

output "AWS_ACCESS_KEY_ID" {
  value = aws_iam_access_key.cognito_admin.id
}

output "AWS_SECRET_ACCESS_KEY" {
  value = {
    type   = "ssm"
    key    = aws_ssm_parameter.secret_key.name
    region = data.aws_region.current.name
    arn    = aws_ssm_parameter.secret_key.arn
  }
}

output "AWS_REGION" {
  value = data.aws_region.current.name
}

output "COGNITO_USER_IDS" {
  value = join(",", aws_cognito_user.default.*.id)
}
