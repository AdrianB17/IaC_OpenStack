# IaC_OpenStack
# Arquitectura OpenStack
La arquitectura cumple con el siguiente criterio de escalabilidad
![requerimineto_openstack](https://github.com/AdrianB17/IaC_OpenStack/assets/97138609/2e8b0c43-bca1-4dbb-a266-9d020b0029df)


![OpenStack drawio (1)](https://github.com/AdrianB17/IaC_OpenStack/assets/97138609/450be520-a315-47d1-bf0e-87838b722b21)


# Ansible
Actualizar los ips de los host administrados

```shell
$ vi /ansible/inventory
```

```ini
[puppet_server]
<ip_puppet_server>  ansible_user=ubuntu ansible_ssh_private_key_file=~/challenger-xx.pem

[puppet_agent]
<ip_puppet_agent> ansible_user=ubuntu ansible_ssh_private_key_file=~/challenger-xx.pem
<ip_puppet_agent> ansible_user=ubuntu ansible_ssh_private_key_file=~/challenger-xx.pem

[puppet_db]
<ip_puppet_db> ansible_user=ubuntu ansible_ssh_private_key_file=~/challenger-xx.pem
```
Actualizar las variables del rol puppet_server

```shell
$ vi /ansible_puppet/roles/puppet_server/defaults/main.yml
```

```ini
---
# defaults file for puppet_server
puppet_server_ip: <ip_puppet_server>
puppet_server_hostname: "puppet"
puppet_version: 8
puppet_distribution_release: "focal"
puppet_server_pkg: "puppetserver"
```
Actualizar las variables del rol puppet_agent

```shell
$ vi /ansible_puppet/roles/puppet_agent/defaults/main.yml
```

```ini
---
# defaults file for puppet_agent
puppet_server_ip: <ip_puppet_server>
puppet_server_hostname: "puppet"
puppet_version: 8
puppet_distribution_release: "focal"
puppet_agent_pkg: "puppet-agent"
puppet_pkg: "puppet"

```
Actualizar las variables del rol puppet_db

```shell
$ vi /ansible_puppet/roles/puppet_db/defaults/main.yml
```

```ini
---
# defaults file for puppet_db
puppet_server_ip: <ip_puppet_server>
puppet_server_hostname: "puppet"
puppet_version: 8
puppet_distribution_release: "focal"
puppet_db_pkg: "puppetdb"
puppet_pkg: "puppet"
```
