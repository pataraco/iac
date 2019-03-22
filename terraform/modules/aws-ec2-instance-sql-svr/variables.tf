variable "ami" {
  description = "AMI to use for the instance"
  type = "string"
}
variable "availability_zone" {
  description = "Availability Zone to use"
  type = "string"
}

variable "create_backup_drive" {
  description = "Create drive for backups? true/false"
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

variable "get_password_data" {
  default = "false"
  description = "If true, wait for password data to become available and retrieve it. Useful for getting the administrator password for instances running Microsoft Windows (default: false)"
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

variable "private_ip" {
  description = "primary private IP"
}

variable "private_ips" {
  description = "list of private IPs to assign the instance"
  type = "list"
}

variable "ebs_kms_key_id" {
  description = "EBS encryption KMS key"
  type = "string"
}

variable "ebs_encryption" {
  default = "true"
  description = "Enables EBS encryption on the volume (default: true)"
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

# B drive

variable "ebs_block_device_delete_on_termination_b" {
  default = "false"
  description = "Whether the volume should be destroyed on termination (default: false)"
  type = "string"
}

variable "ebs_block_device_name_b" {
  default = "xvdb"
  description = "The name of the device to mount"
  type = "string"
}

variable "ebs_block_device_iops_b" {
  default = "3000"
  description = "The amount of provisioned IOPS. Required and only valid for type io1"
  type = "string"
}

variable "ebs_block_device_volume_size_b" {
  default = "100"
  description = "B drive size"
  type = "string"
}

variable "ebs_block_device_volume_type_b" {
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

# F drive

variable "ebs_block_device_delete_on_termination_f" {
  default = "false"
  description = "Whether the volume should be destroyed on termination (default: false)"
  type = "string"
}

variable "ebs_block_device_name_f" {
  default = "xvdf"
  description = "The name of the device to mount"
  type = "string"
}

variable "ebs_block_device_encrypted_f" {
  default = "true"
  description = "Enables EBS encryption on the volume (default: true)"
  type = "string"
}

variable "ebs_block_device_iops_f" {
  default = "3000"
  description = "The amount of provisioned IOPS. Required and only valid for type io1"
  type = "string"
}

variable "ebs_block_device_volume_size_f" {
  default = "500"
  description = "E drive size"
  type = "string"
}

variable "ebs_block_device_volume_type_f" {
  default = "gp2"
  description = "The type of volume. (standard, gp2, io1, sc1, or st1. default: gp2)"
  type = "string"
}

# G drive

variable "ebs_block_device_delete_on_termination_g" {
  default = "false"
  description = "Whether the volume should be destroyed on termination (default: false)"
  type = "string"
}

variable "ebs_block_device_name_g" {
  default = "xvdg"
  description = "The name of the device to mount"
  type = "string"
}

variable "ebs_block_device_encrypted_g" {
  default = "true"
  description = "Enables EBS encryption on the volume (default: true)"
  type = "string"
}

variable "ebs_block_device_iops_g" {
  default = "3000"
  description = "The amount of provisioned IOPS. Required and only valid for type io1"
  type = "string"
}

variable "ebs_block_device_volume_size_g" {
  default = "500"
  description = "E drive size"
  type = "string"
}

variable "ebs_block_device_volume_type_g" {
  default = "gp2"
  description = "The type of volume. (standard, gp2, io1, sc1, or st1. default: gp2)"
  type = "string"
}

# H drive

variable "ebs_block_device_delete_on_termination_h" {
  default = "false"
  description = "Whether the volume should be destroyed on termination (default: false)"
  type = "string"
}

variable "ebs_block_device_name_h" {
  default = "xvdh"
  description = "The name of the device to mount"
  type = "string"
}

variable "ebs_block_device_encrypted_h" {
  default = "true"
  description = "Enables EBS encryption on the volume (default: true)"
  type = "string"
}

variable "ebs_block_device_iops_h" {
  default = "3000"
  description = "The amount of provisioned IOPS. Required and only valid for type io1"
  type = "string"
}

variable "ebs_block_device_volume_size_h" {
  default = "500"
  description = "E drive size"
  type = "string"
}

variable "ebs_block_device_volume_type_h" {
  default = "gp2"
  description = "The type of volume. (standard, gp2, io1, sc1, or st1. default: gp2)"
  type = "string"
}

# T drive

variable "ebs_block_device_delete_on_termination_t" {
  default = "false"
  description = "Whether the volume should be destroyed on termination (default: false)"
  type = "string"
}

variable "ebs_block_device_name_t" {
  default = "xvdt"
  description = "The name of the device to mount"
  type = "string"
}

variable "ebs_block_device_encrypted_t" {
  default = "true"
  description = "Enables EBS encryption on the volume (default: true)"
  type = "string"
}

variable "ebs_block_device_iops_t" {
  default = "3000"
  description = "The amount of provisioned IOPS. Required and only valid for type io1"
  type = "string"
}

variable "ebs_block_device_volume_size_t" {
  default = "500"
  description = "E drive size"
  type = "string"
}

variable "ebs_block_device_volume_type_t" {
  default = "gp2"
  description = "The type of volume. (standard, gp2, io1, sc1, or st1. default: gp2)"
  type = "string"
}

# V drive

variable "ebs_block_device_delete_on_termination_v" {
  default = "false"
  description = "Whether the volume should be destroyed on termination (default: false)"
  type = "string"
}

variable "ebs_block_device_name_v" {
  default = "xvdv"
  description = "The name of the device to mount"
  type = "string"
}

variable "ebs_block_device_encrypted_v" {
  default = "true"
  description = "Enables EBS encryption on the volume (default: true)"
  type = "string"
}

variable "ebs_block_device_iops_v" {
  default = "3000"
  description = "The amount of provisioned IOPS. Required and only valid for type io1"
  type = "string"
}

variable "ebs_block_device_volume_size_v" {
  default = "500"
  description = "E drive size"
  type = "string"
}

variable "ebs_block_device_volume_type_v" {
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
