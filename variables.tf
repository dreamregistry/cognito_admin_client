variable "cognito_user_pool_id" {
  type        = string
  description = "The name of the user pool to create the app client in"
}

variable "cognito_users" {
  type = list(object({
    email = string
    name  = string
  }))
  description = "List of users to create in the user pool"
  default     = []
}
