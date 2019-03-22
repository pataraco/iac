# Common Variables

variable "application" {
  description = "value for resource tag: Application"
}
variable "environment" {
  description = "value for resource tag: Environment"
}

variable "additional_tags" {
  description = "Map of additional tags to tag resources with (merged with other specific tags above)"
  type = "map"
}
variable "vpc_id" {
  description = "VPC Id to get data from"
}
variable "region" {
  default = "us-west-2"
  description = "Region to launch resources in"
}


# DHCP variables

variable "domain_name_private" {
  description = "private DNS domain name for the root domain"
}
variable "domain_name_server_a" {
  description = "IP address of domain name server A"
}

variable "domain_name_server_b" {
  description = "IP address of domain name server B"
}

variable "associate_dhcp_with_vpc" {
  default = true
  description = "associate dhcp options with vpc"
}

