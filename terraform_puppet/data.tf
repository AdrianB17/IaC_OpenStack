// Data source para la primera red privada
data "openstack_networking_network_v2" "private_network_1" {
  name = var.network_name_private_1
}

data "openstack_networking_subnet_v2" "private_subnet_1" {
  name = var.subnet_name_private_1
}

// Data source para la segunda red privada
data "openstack_networking_network_v2" "private_network_2" {
  name = var.network_name_private_2
}

data "openstack_networking_subnet_v2" "private_subnet_2" {
  name = var.subnet_name_private_2
}

// Data source para la red pública
data "openstack_networking_network_v2" "public_network" {
  name = var.network_name_public
}

data "openstack_networking_subnet_v2" "public_subnet" {
  name = var.subnet_name_public
}
