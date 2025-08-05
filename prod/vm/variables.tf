##################################################################
variable "aws_region" {
  type        = string
  description = "AWS region for the provider"
}
##################################################################
variable "vm_instances" {
  type = list(object({
    name                        = string
    ami                         = string
    instance_type               = string
    availability_zone           = string
    subnet                      = string
    associate_public_ip_address = bool
    ebs_optimized               = bool
    enable_api_termination      = bool
    monitoring                  = bool
    key_name                    = string
    security_groups             = list(string)
    tags                        = string
    public_key_path             = string
  }))

  description = "List of VM instances to create with detailed configuration"
}
##################################################################
variable "security_groups" {
  type = map(string)
}
##################################################################
variable "subnets" {
  type = map(object({
    id   = string
    zone = string
  }))
}
##################################################################
variable "ssh_keys" {
  type        = list(string)
  description = "List of SSH public keys"
}
##################################################################