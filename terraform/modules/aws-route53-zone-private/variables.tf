# Common Variables

variable "region" {
  default = "us-west-2"
  description = "Region to launch resources in"
}
variable "vpc_name" {
  default = ""
  description = "Name [tag] of VPC to get data from"
}
variable "vpc_id" {
  default = ""
  description = "VPC ID to associate the private zone with"
}
variable "vpc_id_2" {
  default = "vpc-04611e91b8e2f6d72"
  description = "VPC ID 2 to associate the private zone with"
}

variable "env" {
  description = "used for state file S3 bucket & DynamoDB table name"
}

# Tag Variables

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


# DNS (Route 53) Setting

variable "r53_domain_name_private" {
  description = "private DNS domain name for the environment and application"
}
