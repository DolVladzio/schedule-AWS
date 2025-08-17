##################################################################
locals {
  inventory = templatefile(var.inventory_tpl_path, {
    bastion_ips = {
      for vm_name in var.vms_config : vm_name => var.vms[vm_name].ip
    }

    # private_ips      = module.vms.private_ips
    # private_key_path = var.private_key_path

    # db_host     = module.db.db_hosts[local.db_name]
    # db_user     = module.db.db_users[local.db_name]
    # db_password = module.db.db_passwords[local.db_name]
    # db_port     = module.db.db_ports[local.db_name]
    # db_name     = module.db.db_names[local.db_name]
  })
}
##################################################################
resource "local_file" "ansible_inventory" {
  content  = local.inventory
  filename = var.inventory_ini_path
}
##################################################################