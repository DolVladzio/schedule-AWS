##################################################################
variable "aws_region" {
  type        = string
  description = "AWS region for the provider"
}
##################################################################
variable "nat_eip_ip_list" {
  type = map(object({
    id = string
    ip = string
  }))
}
##################################################################
variable "vms_config" {
  type = list(string)
}
##################################################################
variable "inventory_tpl_path" {}
##################################################################
variable "inventory_ini_path" {}
##################################################################
variable "vms" {
  type = map(object({
    ami    = string
    ip     = string
    sg     = list(string)
    subnet = string
  }))
}
##################################################################
# variable "db" {
#   type = map(object({
#     arn                  = string
#     db_subnet_group_name = string
#     engine               = string
#     engine_version       = string
#     instance_class       = string
#     secret_manager_name  = string
#     security_group_ids   = list(string)
#     storage_type         = string
#     subnets              = list(string)
#   }))
# }
##################################################################