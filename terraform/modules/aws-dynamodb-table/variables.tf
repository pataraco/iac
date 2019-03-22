variable "billing_mode" {
  default = "PROVISIONED"
  description = "Controls how services are charged for read and write throughput and how capacity is managed. (valid values: PROVISIONED and PAY_PER_REQUEST. default: PROVISIONED)"
  type = "string"
}

variable "env" {
  description = "used for 'Env' tag"
  type = "string"
}

variable "hash_key" {
  description = "hash key name"
  type = "string"
}

variable "hash_key_attrib" {
  description = "hash key attributes"
  default = {}
  type = "map"
}

variable "name" {
  description = "Name of DynamoDB table to create"
  type = "string"
}

variable "read_capacity" {
  default = "20"
  description = "Name of DynamoDB table to create"
  type = "string"
}

variable "encryption" {
  default = "true"
  description = "Whether or not to enable encryption at rest using an AWS managed Customer Master Key. If enabled is false then server-side encryption is set to AWS owned CMK (shown as DEFAULT in the AWS console). If enabled is true then server-side encryption is set to AWS managed CMK (shown as KMS in the AWS console). The "
  type = "string"
}

variable "tags" {
  default = {}
  description = "tags to give the table"
  type = "map"
}

variable "write_capacity" {
  default = "20"
  description = "Name of DynamoDB table to create"
  type = "string"
}
