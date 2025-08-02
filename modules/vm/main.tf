##################################################################
locals {
  vms = { for vm in var.vm_instances : vm.name => vm }
}
##################################################################
resource "aws_instance" "vm" {
  for_each = local.vms

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  subnet_id                   = var.subnets[each.value.subnet].id
  associate_public_ip_address = each.value.associate_public_ip_address
  monitoring                  = true
  vpc_security_group_ids      = [
    for sg_name in each.value.security_groups : var.security_groups[sg_name]
  ]
  
  tags = merge(
    each.value.tags,
    { "Name" = each.value.name }
  )

  user_data = templatefile("${path.root}/scripts/setup_ssh.tpl", {
    ssh_keys = join("\n", var.ssh_keys)
  })
}
##################################################################