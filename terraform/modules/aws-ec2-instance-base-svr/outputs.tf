output "id" {
  description = "the instance ID"
  value = "${aws_instance.ec2_instance.id}"
}

output "az" {
  description = "The availability zone of the instance"
  value = "${aws_instance.ec2_instance.availability_zone}"
}

output "key_pair_name" {
  description = "the name of the key pair"
  value = "${aws_instance.ec2_instance.key_name}"
}

output "password" {
  description = "Base-64 encoded encrypted password data for the instance. Useful for getting the administrator password for Windows instances. Attribute only exported if get_password_data is true"
  value = "${aws_instance.ec2_instance.password_data}"
}

output "private_ip" {
  description = "The private IP address assigned to the instance"
  value = "${aws_instance.ec2_instance.private_ip}"
}

output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable"
  value = "${aws_instance.ec2_instance.public_ip}"
}

output "vpc_security_group_ids" {
  description = "The associated security groups in non-default VPC"
  value = "${aws_instance.ec2_instance.vpc_security_group_ids}"
}

output "subnet_id" {
  description = "The VPC subnet ID"
  value = "${aws_instance.ec2_instance.subnet_id}"
}
