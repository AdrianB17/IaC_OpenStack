// Variables de autenticación de OpenStack
variable "auth_url" {
  description = "The authentication URL for OpenStack"
  type        = string
}

variable "tenant_name" {
  description = "The tenant name for OpenStack"
  type        = string
}

variable "user_name" {
  description = "The user name for OpenStack"
  type        = string
}

variable "password" {
  description = "The password for OpenStack"
  type        = string
}

// Variables para las redes y subredes existentes
variable "network_name_private_1" {
  description = "The name of the first private network"
  type        = string
}

variable "subnet_name_private_1" {
  description = "The name of the first private subnet"
  type        = string
}

variable "network_name_private_2" {
  description = "The name of the second private network"
  type        = string
}

variable "subnet_name_private_2" {
  description = "The name of the second private subnet"
  type        = string
}

variable "network_name_public" {
  description = "The name of the public network"
  type        = string
}

variable "subnet_name_public" {
  description = "The name of the public subnet"
  type        = string
}

// Variables para configurar los servidores
variable "server_flavor" {
  description = "The flavor to use for the Puppet server"
  type        = string
}

variable "server_image" {
  description = "The image to use for the Puppet server"
  type        = string
}

variable "agent_count" {
  description = "The number of Puppet agents"
  type        = number
  default     = 1
}

variable "agent_flavor" {
  description = "The flavor to use for the Puppet agents"
  type        = string
}

variable "agent_image" {
  description = "The image to use for the Puppet agents"
  type        = string
}

variable "db_flavor" {
  description = "The flavor to use for the Puppet DB"
  type        = string
}

variable "db_image" {
  description = "The image to use for the Puppet DB"
  type        = string
}

variable "key_pair" {
  description = "The key pair to use for the instances"
  type        = string
}
