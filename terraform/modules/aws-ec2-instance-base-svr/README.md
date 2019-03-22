# SQL Server AWS EC2 Instance Terraform module

Terraform module which creates an EC2 instance in AWS for a SQL Server.
Also attaches 5 additional EBS volumes.

This type of resource is supported:

* [aws_instance](https://www.terraform.io/docs/providers/aws/r/instance.html)

## Usage

```hcl
module "sql_svr" {
  source = "path/to/modules/aws-ec2-instance-sql-svr"

  ami = "ami-1234567890"
  disable_api_termination = "true"
  instance_type = "m4.large"
  key_name = "qa-us-east-1"
  monitoring = "true"
  root_block_device_delete_on_termination = "true"
  root_block_device_volume_size = "100"
  ebs_block_device_volume_size_e = "50"
  ebs_block_device_volume_size_l = "100"
  subnet_id = "subnet-1234567890"
  tags_name = "sql-server-1"
  tags_env = "dev"
  tags_additional = {
    App = "BaaS 3.0"
    Role = "SQL Server"
    Tier = "Data"
  }
  user_data = "${data.template_file.user_data.rendered}"
  vpc_security_group_ids = ["sg-1234567890"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami | AMI to use for the instance | string | - | yes |
| disable_api_termination | If true, enables EC2 Instance Termination Protection | string | `true` | no |
| ebs_optimized | If true, the instance will be EBS-optimized | string | `true` | no |
| get_password_data | If true, wait for and retrieve password data | string | `false` | no |
| iam_instance_profile | The IAM Instance Profile to launch the instance with | string | `` | no |
| instance_count | Number of instances to create | string | `1` | no |
| instance_type | EC2 instance type to use | string | - | yes |
| key_name | EC2 keypair to use | string | - | yes |
| monitoring | If true, the launched EC2 instance will have detailed monitoring enabled | string | `false` | no |
| root_block_device_delete_on_termination | Whether the root drive should be deleted on termination | string | `true` | no |
| root_block_device_iops | Amount of provisioned IOPS for root. Required and only valid for type: io1 | string | `3000` | no |
| root_block_device_volume_size | Root drive size | string | `100` | no |
| root_block_device_volume_type | Root drive volume type | string | `gp2` | no |
| ebs_block_device_delete_on_termination_e | Whether the drive E: should be deleted on termination | string | `false` | no |
| ebs_block_device_name_e | Device name for drive E: | string | `xvde` | no |
| ebs_block_device_encrypted_e | Enable EBS encryption for drive E: | string | `true` | no |
| ebs_block_device_iops_e | Amount of provisioned IOPS for drive E:. Required and only valid for type: io1 | string | `3000` | no |
| ebs_block_device_volume_size_e | Drive E: size | string | `100` | no |
| ebs_block_device_volume_type_e | Drive E: volume type | string | `gp2` | no |
| ebs_block_device_delete_on_termination_l | Whether the drive L: should be deleted on termination | string | `false` | no |
| ebs_block_device_name_l | Device name for drive L: | string | `xvdl` | no |
| ebs_block_device_encrypted_l | Enable EBS encryption for drive L: | string | `true` | no |
| ebs_block_device_iops_l | Amount of provisioned IOPS for drive L:. Required and only valid for type: io1 | string | `3000` | no |
| ebs_block_device_volume_size_l | Drive L: size | string | `500` | no |
| ebs_block_device_volume_type_l | Drive L: volume type | string | `gp2` | no |
| subnet_id | ID of subnet to launch instance in | string | - | yes |
| tags_name | Name tag (Name) to tag the instance with | string | - | yes |
| tags_env | Environment tag (Env) to tag the instance with | string | - | yes |
| tags_additional | Additional tags to tag the instance with | map | `<map>` | no |
| user_data | The user data script to run on the instance | string | - | yes |
| vpc_security_group_ids | A list of security group IDs to associate with | list | `<list>` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The instance ID |
| az | The availability zone of the instances |
| key_pair_name | The name of the key pair |
| password | Base-64 encoded encrypted password data for the instance (administrator password for Windows) |
| private_ip | The private IP address assigned to the instance |
| public_ip | The public IP address assigned to the instance, if applicable |
| vpc_security_group_ids | The associated security groups in non-default VPC |
| subnet_id | VPC subnet ID |
