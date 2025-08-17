[all:vars]
ansible_ssh_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[vm_ips]
%{ for vm_name, vm_ip in bastion_ips }
${vm_name} ansible_host=${vm_ip}
%{ endfor }