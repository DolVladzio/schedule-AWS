##################################################################
data "aws_db_instance" "main" {
  for_each = toset(var.dbs_config)

  db_instance_identifier = each.key
}
##################################################################
data "aws_secretsmanager_secret" "db_secret" {
  for_each = var.db_secret_managers

  name = each.value.secret_manager
}
##################################################################
data "aws_secretsmanager_secret_version" "db_secret_version" {
  for_each = data.aws_secretsmanager_secret.db_secret

  secret_id = each.value.id
}
##################################################################
locals {
  db_credentials = {
    for k, v in data.aws_secretsmanager_secret_version.db_secret_version :
    k => jsondecode(v.secret_string)
  }

  inventory = templatefile(var.inventory_tpl_path, {
    bastion_ips = {
      for vm_name in var.vms_config : vm_name => var.vms[vm_name].ip
    }

    db_info = {
      for db_name in var.dbs_config : db_name => {
        db_host     = data.aws_db_instance.main[db_name].address
        db_name     = data.aws_db_instance.main[db_name].db_name
        db_user     = local.db_credentials[db_name].username
        db_password = local.db_credentials[db_name].password
      }
    }
  })
}
##################################################################
resource "local_file" "ansible_inventory" {
  content  = local.inventory
  filename = var.inventory_ini_path
}
##################################################################