terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {}

resource "random_pet" "user_name" {
  length    = 2
  separator = "-"
}

resource "aws_iam_user" "cognito_admin" {
  name = random_pet.user_name.id
}

resource "aws_iam_access_key" "cognito_admin" {
  user = aws_iam_user.cognito_admin.name
}

resource "aws_ssm_parameter" "secret_key" {
  name  = "/cognito_admin_client/${aws_iam_user.cognito_admin.name}/secret_key"
  type  = "SecureString"
  value = aws_iam_access_key.cognito_admin.secret
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


resource "aws_iam_user_policy" "cognito_specific_pool_admin" {
  name = "CognitoPoolAdmin-${aws_iam_user.cognito_admin.name}"
  user = aws_iam_user.cognito_admin.name

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cognito-idp:List*",
          "cognito-idp:Describe*",
          "cognito-idp:Get*",
          "cognito-idp:Admin*"
        ],
        Resource = "arn:aws:cognito-idp:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:userpool/${var.cognito_user_pool_id}"
      },
    ]
  })
}

resource "aws_cognito_user" "default" {
  count        = length(var.cognito_users)
  user_pool_id = var.cognito_user_pool_id
  username     = var.cognito_users[count.index].email
  attributes   = {
    email = var.cognito_users[count.index].email
    name  = var.cognito_users[count.index].name
  }
}
