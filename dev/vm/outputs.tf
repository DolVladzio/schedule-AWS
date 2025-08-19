##################################################################
output "vms" {
  description = "Map of vms and their info"
  value = { for k, vm in aws_instance.vm : k => {
    ami    = vm.ami
    ip     = vm.public_ip
    subnet = vm.subnet_id
    sg     = vm.vpc_security_group_ids
    }
  }
}
##################################################################