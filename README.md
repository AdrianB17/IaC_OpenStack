# IaC_OpenStack

# Criterio de escalibilidad
La arquitectura cumple con el siguiente criterio de escalabilidad

| Componente | Estabilidad Vertical | Estabilidad Horizontal |
|------|---------|---------|
|Puppet_server|Si|No|
|Puppet_server|Si|Si|
|Puppet_server|Si|No|

# Arquitectura OpenStack

La arquitectura cuenta con un router para la comunicacion entre la red publica y privada
![OpenStack drawio (1)](https://github.com/AdrianB17/IaC_OpenStack/assets/97138609/450be520-a315-47d1-bf0e-87838b722b21)

# Terraform
Crear el archivo 'terraform.tfvars', para asignar las variables, el ejemplo se muestra en el archivo 'terraform.tfvars.example'

```shell
$ vi /terraform_puppet/terraform.tfvars
```

```ini
auth_url    = "http://10.100.1.31:5000"
tenant_name = "challenger-##"
user_name   = "challenger-##"
password    = ""
key_pair = "challenger-##"

network_name_private_1 = "PRIVATE-1"
subnet_name_private_1  = "private-subnet-1"

network_name_private_2 = "PRIVATE-2"
subnet_name_private_2  = "private-subnet-2"

network_name_public = "PUBLIC"
subnet_name_public  = "public-subnet-1"

server_flavor = "m1.medium"
server_image  = "Ubuntu 22.04 LTS"

agent_count   = 2
agent_flavor  = "m1.medium"
agent_image   = "Ubuntu 22.04 LTS"

db_flavor = "m1.medium"
db_image  = "Ubuntu 22.04 LTS"
```

Considerar las siguientes variables:

| Variable | Definicion |
|------|---------|
|key_pair|Si|
|server_flavor|Si|
|agent_count|Si|
|agent_flavor|Si|
|db_flavor|Si|

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
