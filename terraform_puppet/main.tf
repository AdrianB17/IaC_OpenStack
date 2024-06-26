// Instancia del servidor Puppet
resource "openstack_compute_instance_v2" "puppet_server" {
  name            = "puppet-server"
  flavor_name     = var.server_flavor
  image_name      = var.server_image
  key_pair        = var.key_pair
  security_groups = [openstack_networking_secgroup_v2.puppet_secgroup.name]
  // Agregar interfaz de red pública si se requiere acceso público
  network {
    uuid = data.openstack_networking_network_v2.public_network.id
  }
}

// Crear una IP flotante para el servidor Puppet
resource "openstack_networking_floatingip_v2" "puppet_server_floatingip" {
  pool = "public"
}

// Asociar la IP flotante al servidor Puppet
resource "openstack_compute_floatingip_associate_v2" "puppet_server_floatingip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.puppet_server_floatingip.address
  instance_id = openstack_compute_instance_v2.puppet_server.id
}

// Instancias de los agentes Puppet
resource "openstack_compute_instance_v2" "puppet_agent" {
  count           = var.agent_count
  name            = "puppet-agent-${count.index}"
  flavor_name     = var.agent_flavor
  image_name      = var.agent_image
  key_pair        = var.key_pair
  security_groups = [openstack_networking_secgroup_v2.puppet_secgroup.name]
  network {
    uuid = data.openstack_networking_network_v2.private_network_2.id
  }
}

// Instancia de la base de datos Puppet
resource "openstack_compute_instance_v2" "puppet_db" {
  name            = "puppet-db"
  flavor_name     = var.db_flavor
  image_name      = var.db_image
  key_pair        = var.key_pair
  security_groups = [openstack_networking_secgroup_v2.puppet_secgroup.name]
  network {
    uuid = data.openstack_networking_network_v2.private_network_1.id
  }
}

// Grupo de seguridad para las instancias Puppet
resource "openstack_networking_secgroup_v2" "puppet_secgroup" {
  name        = "puppet-secgroup"
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
  security_group_id = openstack_networking_secgroup_v2.puppet_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "puppet_secgroup_puppet" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8140
  port_range_max    = 8140
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.puppet_secgroup.id
}

// Reglas para permitir la comunicación entre Puppet components
resource "openstack_networking_secgroup_rule_v2" "puppet_secgroup_internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "192.168.10.0/24"
  security_group_id = openstack_networking_secgroup_v2.puppet_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "puppet_secgroup_internal_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "192.168.20.0/24"
  security_group_id = openstack_networking_secgroup_v2.puppet_secgroup.id
}
