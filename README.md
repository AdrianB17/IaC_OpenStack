# IaC_OpenStack

Nos enfocamos en el uso de herramientas de infraestructura/configuración como código para el despliegue de aplicaciones o sistemas sobre plataformas cloud. En específico, se pretende utilizar Terraform y Ansible para desplegar Puppet dentro de una nube privada basada en OpenStack.

Por simplicidad, se debe cumplir el siguiente criterio de escalabilidad durante el desarrollo de los módulos de Terraform o playbooks de Ansible:

| Componente     | Estabilidad Vertical | Estabilidad Horizontal |
|----------------|----------------------|------------------------|
| Puppet_server  | Si                   | No                     |
| Puppet_server  | Si                   | Si                     |
| Puppet_server  | Si                   | No                     |


Mediante Terraform y Ansible, deberá generar y configurar la infraestructura necesaria para desplegar Puppet, el cual estará compuesto por:
 
![image](https://github.com/AdrianB17/IaC_OpenStack/assets/97138609/998057de-dd05-4555-8827-677787f39fe2)

# Arquitectura OpenStack

La arquitectura cuenta con un router para la comunicacion entre la red publica y privada

<div align="center">
 
![OpenStack drawio (1)](https://github.com/AdrianB17/IaC_OpenStack/assets/97138609/450be520-a315-47d1-bf0e-87838b722b21)
 
</div>

● Router: El router se utiliza para conectar las redes privadas con la red pública, permitiendo que el tráfico salga de las redes privadas hacia Internet y viceversa. Esto proporciona una capa de enrutamiento y control del tráfico.

● IP Flotante: Las IPs flotantes se asignan a instancias específicas para hacerlas accesibles desde la red pública. Esto es útil para exponer solo los servicios necesarios a Internet, mientras se mantiene el resto de la infraestructura segura en redes privadas.

IMPORTANTE: Exponer todas las instancias directamente en la red pública aumenta el riesgo de ataques y acceso no autorizado.

# Terraform
Terraform es una herramienta de infraestructura como código (IaC) que automatiza la creación y configuración de recursos en OpenStack, como redes, subredes, routers, instancias y direcciones IP flotantes, asegurando que tu infraestructura sea creada de manera consistente y reproducible.

__Modulo Terraform__

Un módulo de Terraform se organiza en un conjunto de archivos y directorios que juntos definen una parte específica de la infraestructura.
```shell
$ tree /terraform_puppet/
├── main.tf
├── data.tf
├── vars.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars
├── providers.tfvars.example
└── README.md
```
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

| Variable | Definicion | Escalabilidad |
|------|---------|---------|
|auth_url|URL del servicio de autenticación||
|tenant_name|Nombre del tenant||
|key_pair|Nombre del key pair para el acceso SSH||
|server_flavor|Tamaño de la instancia del servidor|Vertical|
|server_image|Imagen del sistema operativo del servidor||
|agent_count|Número de agentes a desplegar|Horizontal|
|agent_flavor|Tamaño de la instancia del agente|Vertical|
|agent_image|Imagen del sistema operativo del agente	||
|db_flavor|Tamaño de la instancia de la base de datos|Vertical|
|db_image|Imagen del sistema operativo de la base de datos||

IMPORTANTE: Revisar la documentación par asignar el adecuado flavor(disco y memoria) para cada instancia server, agent y db.

__Despliegue__

Luego de actulizar mi archivo terraform.tfvars, desplegar mi infraestructura en Openstack con los siguientes comandos:

Este comando prepara el directorio de trabajo descargando los proveedores necesarios y configurando el entorno:
```shell
$ terraform init
```

Este comando crea un plan de ejecución, mostrando los cambios que Terraform realizará en la infraestructura. Es una buena práctica revisar el plan cuidadosamente antes de aplicar los cambios:
```shell
$ terraform plan
```

Aplica el plan guardado para realizar los cambios necesarios en la infraestructura:
```shell
$ terraform apply
```

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
Luego de actulizar el inventory y variables, ejecutar el rol playbook:

```shell
challenger-xx@challenge-3-pivote:~/IaC_OpenStack/ansible_puppet$ ansible-playbook -i inventory playbooks/puppet.yml
```

Validar el despliegue de Puppet 

```shell
ubuntu@puppet-server:~$ sudo /opt/puppetlabs/bin/puppetserver ca list
Requested Certificates:
    puppet-agent-0.openstacklocal       (SHA256)  9D:BC:06:A5:40:3C:6E:06:B6:A3:5A:25:01:61:30:82:BF:0A:2E:24:02:08:CF:A1:3F:C1:1F:C2:A6:22:F2:3B
    puppet-agent-1.openstacklocal       (SHA256)  2F:8F:23:AB:25:71:E9:25:49:AB:88:72:9A:F2:B2:BB:92:1E:75:65:6A:C7:3D:34:2E:B7:BF:B2:8B:26:FE:1E
    puppet-db.openstacklocal            (SHA256)  AC:FF:F1:05:90:90:5E:4F:1D:B2:A8:39:29:A4:06:5F:DD:BA:FD:F5:90:3E:DF:1C:FD:93:99:A4:5F:80:B5:71
```
