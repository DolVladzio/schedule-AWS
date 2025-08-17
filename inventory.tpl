[all:vars]
ansible_ssh_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[vm_ips]
%{ for vm_name, vm_ip in bastion_ips ~}
${vm_name} ansible_host=${vm_ip}
%{ endfor ~}

[dbs]
%{ for name, db in db_info ~}
${name} ansible_host=${db.db_host} db_name=${db.db_name} db_user=${db.db_user} db_password=${db.db_password}
%{ endfor ~}

[load_balancers]
%{ for name, ip in lb_ips ~}
${name}=${ip}
%{ endfor ~}