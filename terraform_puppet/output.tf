// Output de la IP del servidor Puppet en la red privada
output "puppet_server_private_ip" {
  value = openstack_compute_instance_v2.puppet_server.network[0].fixed_ip_v4
}

// Output de la IP pública del servidor Puppet (si se requiere)
output "puppet_server_public_ip" {
  value = openstack_compute_instance_v2.puppet_server.network[0].fixed_ip_v4
}

// Output de las IPs de los agentes Puppet
output "puppet_agent_ips" {
  value = [for instance in openstack_compute_instance_v2.puppet_agent : instance.network[0].fixed_ip_v4]
}

// Output de la IP de la base de datos Puppet
output "puppet_db_ip" {
  value = openstack_compute_instance_v2.puppet_db.network[0].fixed_ip_v4
}
