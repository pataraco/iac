variable "env" {
  description = "used for 'Env' tag"
  type = "string"
}

variable "name" {
  description = "Name of security group to create"
  type = "string"
}

variable "description" {
  description = "description of security group to create"
  type = "string"
}

variable "vpc_id" {
  description = "VPC ID to create security group in"
  type = "string"
}

variable "cidr_blocks_1" {
  default = []
  description = "CIDR blocks to allow traffic from for ingress rule"
  type = "list"
}
variable "from_to_proto_desc_cidrs_1" {
  default = []
  description = "ports, protocol and description to allow traffic from for ingress rule"
  type = "list"
}
variable "self_cidrs_1" {
  default = "false"
  description = "If true, the group itself will be added as a source to this rule (default: false)"
}

variable "cidr_blocks_2" {
  default = []
  description = "CIDR blocks to allow traffic from for ingress rule"
  type = "list"
}
variable "from_to_proto_desc_cidrs_2" {
  default = []
  description = "ports, protocol and description to allow traffic from for ingress rule"
  type = "list"
}
variable "self_cidrs_2" {
  default = "false"
  description = "If true, the group itself will be added as a source to this rule (default: false)"
}

variable "cidr_blocks_3" {
  default = []
  description = "CIDR blocks to allow traffic from for ingress rule"
  type = "list"
}
variable "from_to_proto_desc_cidrs_3" {
  default = []
  description = "ports, protocol and description to allow traffic from for ingress rule"
  type = "list"
}
variable "self_cidrs_3" {
  default = "false"
  description = "If true, the group itself will be added as a source to this rule (default: false)"
}

variable "cidr_blocks_4" {
  default = []
  description = "CIDR blocks to allow traffic from for ingress rule"
  type = "list"
}
variable "from_to_proto_desc_cidrs_4" {
  default = []
  description = "ports, protocol and description to allow traffic from for ingress rule"
  type = "list"
}
variable "self_cidrs_4" {
  default = "false"
  description = "If true, the group itself will be added as a source to this rule (default: false)"
}

variable "cidr_blocks_5" {
  default = []
  description = "CIDR blocks to allow traffic from for ingress rule"
  type = "list"
}
variable "from_to_proto_desc_cidrs_5" {
  default = []
  description = "ports, protocol and description to allow traffic from for ingress rule"
  type = "list"
}
variable "self_cidrs_5" {
  default = "false"
  description = "If true, the group itself will be added as a source to this rule (default: false)"
}

variable "sgid_1" {
  default = ""
  description = "Security Group IP to allow traffic from for ingress rule"
}
variable "from_to_proto_desc_sgid_1" {
  default = []
  description = "ports, protocol and description to allow traffic from for ingress rule"
  type = "list"
}

variable "sgid_2" {
  default = ""
  description = "Security Group IP to allow traffic from for ingress rule"
}
variable "from_to_proto_desc_sgid_2" {
  default = []
  description = "ports, protocol and description to allow traffic from for ingress rule"
  type = "list"
}

variable "sgid_3" {
  default = ""
  description = "Security Group IP to allow traffic from for ingress rule"
}
variable "from_to_proto_desc_sgid_3" {
  default = []
  description = "ports, protocol and description to allow traffic from for ingress rule"
  type = "list"
}

variable "sgid_4" {
  default = ""
  description = "Security Group IP to allow traffic from for ingress rule"
}
variable "from_to_proto_desc_sgid_4" {
  default = []
  description = "ports, protocol and description to allow traffic from for ingress rule"
  type = "list"
}

variable "sgid_5" {
  default = ""
  description = "Security Group IP to allow traffic from for ingress rule"
}
variable "from_to_proto_desc_sgid_5" {
  default = []
  description = "ports, protocol and description to allow traffic from for ingress rule"
  type = "list"
}
