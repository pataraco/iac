# Common Variables

variable "environment" {
}
variable "region" {
}

variable "vpc_name" {
  default     = ""
  description = "Name [tag] of VPC to get data from"
}

# Tag Variables

variable "tier" {
  description = "value for resource tag: Tier"
}

variable "tags" {
  description = "Map of additional tags to tag resources with (merged with other specific tags above)"
  type        = map(string)
}

# VPC
variable "cidr" {
  description = "CIDR to assign to VPC"
}
