// Instancia del servidor Puppet
resource "openstack_compute_instance_v2" "puppet_server" {
  name            = "puppet-server"
  flavor_name     = var.server_flavor
  image_name      = var.server_image
  key_pair        = var.key_pair
  security_groups = [
    openstack_networking_secgroup_v2.puppet_secgroup_ssh.id, 
    openstack_networking_secgroup_v2.puppet_secgroup_port.id
  ]
  // Agregar interfaz de red pública si se requiere acceso público
  network {
    uuid = data.openstack_networking_network_v2.public_network.id
  }
}

// Instancias de los agentes Puppet
resource "openstack_compute_instance_v2" "puppet_agent" {
  count           = var.agent_count
  name            = "puppet-agent-${count.index}"
  flavor_name     = var.agent_flavor
  image_name      = var.agent_image
  key_pair        = var.key_pair
  security_groups = [openstack_networking_secgroup_v2.puppet_secgroup_ssh.name]
  network {
    uuid = data.openstack_networking_network_v2.public_network.id
  }
}

// Instancia de la base de datos Puppet
resource "openstack_compute_instance_v2" "puppet_db" {
  name            = "puppet-db"
  flavor_name     = var.db_flavor
  image_name      = var.db_image
  key_pair        = var.key_pair
  security_groups = [openstack_networking_secgroup_v2.puppet_secgroup_ssh.name]
  network {
    uuid = data.openstack_networking_network_v2.public_network.id
  }
}

// Grupo de seguridad para las instancias Puppet
resource "openstack_networking_secgroup_v2" "puppet_secgroup_ssh" {
  name        = "Allow SSH from localhost"
  description = "Security group for Puppet instances"
}

// Reglas de seguridad para SSH y comunicación interna
resource "openstack_networking_secgroup_rule_v2" "puppet_secgroup_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.puppet_secgroup_ssh.id
}

// Grupo de seguridad para las instancia Puppet Server
resource "openstack_networking_secgroup_v2" "puppet_secgroup_port" {
  name        = "Allow port 8140"
  description = "Security group for Puppet server"
}

// Reglas de seguridad para SSH y comunicación interna
resource "openstack_networking_secgroup_rule_v2" "puppet_secgroup_port" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8140
  port_range_max    = 8140
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.puppet_secgroup_port.id
}
