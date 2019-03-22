variable "ami" {
  description = "AMI to use for the instance"
  type = "string"
}

variable "associate_public_ip_address" {
  default = "false"
  description = "Associate a public ip address with an instance in a VPC"
  type = "string"
}

variable "disable_api_termination" {
  default = "true"
  description = "If true, enables EC2 Instance Termination Protection (default: true)"
  type = "string"
}

variable "ebs_optimized" {
  default = "true"
  description = "If true, the instance will be EBS-optimized (default: true)"
  type = "string"
}

variable "create_e_drive" {
  default = true
  description = "Create drive true/false"
  type = "string"
}

variable "create_l_drive" {
  default = true
  description = "Create drive true/false"
  type = "string"
}


variable "ebs_kms_key_id" {
  description = "EBS encryption KMS key"
  type = "string"
}

variable "availability_zone" {
  description = "Availability Zone to use"
  type = "string"
}

variable "iam_instance_profile" {
  default = ""
  description = "The IAM Instance Profile to launch the instance with"
  type = "string"
}

variable "instance_count" {
  default = "1"
  description = "Number of EC2 instances to create"
  type = "string"
}

variable "instance_type" {
  description = "EC2 instance type to use"
  type = "string"
}

variable "key_name" {
  description = "EC2 keypair to use"
  type = "string"
}

variable "monitoring" {
  default = "false"
  description = "If true, the launched instance will have detailed monitoring enabled (default: false)"
  type = "string"
}

# root drive

variable "root_block_device_delete_on_termination" {
  default = "true"
  description = "Whether the volume should be destroyed on termination (default: true)"
  type = "string"
}

variable "root_block_device_iops" {
  default = "3000"
  description = "The amount of provisioned IOPS. Required and only valid for type io1"
  type = "string"
}

variable "root_block_device_volume_size" {
  default = "100"
  description = "root drive size"
  type = "string"
}

variable "root_block_device_volume_type" {
  default = "gp2"
  description = "The type of volume. (standard, gp2, io1, sc1, or st1. default: gp2)"
  type = "string"
}

# E drive

variable "ebs_block_device_delete_on_termination_e" {
  default = "false"
  description = "Whether the volume should be destroyed on termination (default: false)"
  type = "string"
}

variable "ebs_block_device_name_e" {
  default = "xvde"
  description = "The name of the device to mount"
  type = "string"
}

variable "ebs_block_device_encrypted_e" {
  default = "true"
  description = "Enables EBS encryption on the volume (default: true)"
  type = "string"
}

variable "ebs_block_device_iops_e" {
  default = "3000"
  description = "The amount of provisioned IOPS. Required and only valid for type io1"
  type = "string"
}

variable "ebs_block_device_volume_size_e" {
  default = "100"
  description = "E drive size"
  type = "string"
}

variable "ebs_block_device_volume_type_e" {
  default = "gp2"
  description = "The type of volume. (standard, gp2, io1, sc1, or st1. default: gp2)"
  type = "string"
}

# L drive

variable "ebs_block_device_delete_on_termination_l" {
  default = "false"
  description = "Whether the volume should be destroyed on termination (default: false)"
  type = "string"
}

variable "ebs_block_device_name_l" {
  default = "xvdl"
  description = "The name of the device to mount"
  type = "string"
}

variable "ebs_block_device_encrypted_l" {
  default = "true"
  description = "Enables EBS encryption on the volume (default: true)"
  type = "string"
}

variable "ebs_block_device_iops_l" {
  default = "3000"
  description = "The amount of provisioned IOPS. Required and only valid for type io1"
  type = "string"
}

variable "ebs_block_device_volume_size_l" {
  default = "500"
  description = "E drive size"
  type = "string"
}

variable "ebs_block_device_volume_type_l" {
  default = "gp2"
  description = "The type of volume. (standard, gp2, io1, sc1, or st1. default: gp2)"
  type = "string"
}

variable "subnet_id" {
  description = "subnet to place instance in"
  type = "string"
}

variable "tags_name" {
  description = "Name tag (Name) to give the instance"
  type = "string"
}

variable "tags_env" {
  description = "Environment tag (Env) to give the instance"
  type = "string"
}

variable "tags_additional" {
  default = {}
  description = "Additional tags to give the instance"
  type = "map"
}

variable "user_data" {
  description = "User data script to run"
  type = "string"
}

variable "vpc_security_group_ids" {
  default = []
  description = "A list of security group IDs to associate with"
  type = "list"
}
