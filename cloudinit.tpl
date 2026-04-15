#cloud-config

merge_how:
 - name: list
   settings: [replace]
 - name: dict
   settings: [replace]

users:
  - name: ${user}
    gecos: ${user}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, ${admin_group}
    lock_passwd: true
    ssh_authorized_keys:
      - ${ssh_key}
    homedir: /home/${user}
  - name: ${image_user}
    gecos: ${image_user}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, ${admin_group}
    lock_passwd: true
    ssh_authorized_keys:
      - ${ssh_key}
fqdn: ${name}

bootcmd:
  - install -d ${workfolder}
  - chown ${image_user}:${image_user} ${workfolder}
  - chmod 755 ${workfolder}
