
variable "resource_group_name" {
  type        = string
  description = "Existing resource group where the IKS cluster will be provisioned."
}

variable "ibmcloud_api_key" {
  type        = string
  description = "The api key for IBM Cloud access"
}

variable "region" {
  type        = string
  description = "Region for VLANs defined in private_vlan_number and public_vlan_number."
}

variable "cluster_flavor" {
  type        = string
  description = "The machine type that will be provisioned for classic infrastructure"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
  default     = ""
}

variable "cluster_exists" {
  type        = bool
  description = "Flag indicating if the cluster already exists (true or false)"
}

variable "cluster_login" {
  type        = bool
  description = "Flag indicating to login cluster (true or false)"
}

variable "name_prefix" {
  type        = string
  description = "Prefix name that should be used for the cluster and services. If not provided then resource_group_name will be used"
  default     = ""
}

variable "cluster_vpc_subnet_count" {
  type        = number
  description = "The number of subnets to create for the VPC instance"
  default     = 0
}

variable "cluster_vpc_name" {
  type        = string
  description = "Name of the VPC instance that will be used"
}

variable "worker_count" {
  type        = number
}

variable "ocp_version" {
  type        = string
  default     = "4.6"
}

variable "mysls_key" {
  type        = string
  description = "sls entitlement key"

}

variable "mybas_dbpassword" {
  type        = string
  description = "bas db password"

}

variable "mybas_grafapassword" {
  type        = string
  description = "bas grafana password"

} 

variable "mymas_key" {
  type        = string
  description = "IBM entitlement key for MAS"
}