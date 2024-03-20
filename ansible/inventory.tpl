[APIG]
${APIG}

[kafka]
${kafka}

[instances]
${APIG}
${kafka}

[instances:vars]
ansible_ssh_user=ubuntu
ansible_ssh_private_key_file= ./ansible-key.pem
ansible_ssh_common_args='-o StrictHostKeyChecking=no'