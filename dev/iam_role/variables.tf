##################################################################
variable "aws_region" {
  type        = string
  description = "AWS region for the provider"
}
##################################################################
variable "iam_role" {
  type = map(object({
    name              = string
    version           = string
    effect            = string
    principal_service = string
    action            = string
    policy_arn        = list(string)
  }))
  description = "AWS aim roles and policies"
}
##################################################################
variable "iam_user" {
  type = map(object({
    user = string
    tags = string
    groups = list(string)
  }))
  description = "IAM users"
}
##################################################################
variable "iam_groups" {
  type = map(object({
    name       = string
    path       = string
    policy_arn = list(string)
  }))
  description = "IAM groups"
}
##################################################################