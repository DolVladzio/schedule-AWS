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
  }))
  description = "AWS aim role"
}
##################################################################
variable "iam_role_policy_attachment" {
  type = list(object({
    role       = string
    policy_arn = string
  }))
  description = "AWS aim role policy attachment"
}
##################################################################