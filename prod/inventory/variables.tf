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
variable "dbs_config" {
  type = list(string)
}
##################################################################
variable "inventory_tpl_path" {}
##################################################################
variable "inventory_ini_path" {}
##################################################################
variable "db_secret_managers" {
  type = map(object({
    db_name = string
    secret_manager = string
  }))
}
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