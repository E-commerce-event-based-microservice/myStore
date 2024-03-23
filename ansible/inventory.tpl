[APIG]
${APIG} 

[APIG:alpIp]
albIp=${albIp}

[kafka]
${kafka}

[instances]
${APIG}
${kafka}

[instances:vars]
ansible_ssh_user=ubuntu
ansible_ssh_common_args='-o StrictHostKeyChecking=no'