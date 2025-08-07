##################################################################
variable "aws_region" {
  type        = string
  description = "AWS region for the provider"
}
##################################################################
variable "iam_role" {
  type = list(object({
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