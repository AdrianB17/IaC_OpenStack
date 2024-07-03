// Router que conecta la red privada a la red pública
resource "openstack_networking_router_v2" "router_1" {
  name                = "router-public-subnet-1"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public_network.id
}

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
// Crear una floating IP para Puppet Server
resource "openstack_networking_floatingip_v2" "floatip_puppet_agent" {
  count = var.agent_count
  pool = "PUBLIC"
}

resource "openstack_compute_instance_v2" "puppet_agent" {
  count           = var.agent_count
  name            = "puppet-agent-${count.index}"
  flavor_name     = var.agent_flavor
  image_name      = var.agent_image
  key_pair        = var.key_pair
  security_groups = [openstack_networking_secgroup_v2.puppet_secgroup_ssh.name]
  network {
    uuid = data.openstack_networking_network_v2.private_network_1.id
  }
}

resource "openstack_compute_floatingip_associate_v2" "puppet_agent_fip" {
  count       = var.agent_count
  floating_ip = openstack_networking_floatingip_v2.floatip_puppet_agent[count.index].address
  instance_id = openstack_compute_instance_v2.puppet_agent[count.index].id
}

// Instancia de la base de datos Puppet
// Crear una floating IP para Puppet Server
resource "openstack_networking_floatingip_v2" "floatip_puppet_db" {
  pool = "PUBLIC"
}

resource "openstack_compute_instance_v2" "puppet_db" {
  name            = "puppet-db"
  flavor_name     = var.db_flavor
  image_name      = var.db_image
  key_pair        = var.key_pair
  security_groups = [openstack_networking_secgroup_v2.puppet_secgroup_ssh.name]
  network {
    uuid = data.openstack_networking_network_v2.private_network_1.id
  }
}

resource "openstack_compute_floatingip_associate_v2" "puppet_db_fip" {
  floating_ip = openstack_networking_floatingip_v2.floatip_puppet_db.address
  instance_id = openstack_compute_instance_v2.puppet_db.id
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


