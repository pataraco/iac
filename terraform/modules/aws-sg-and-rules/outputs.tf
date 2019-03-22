output "arn" {
  description = "the ARN of the security group"
  value = "${aws_security_group.this.arn}"
}

output "id" {
  description = "the ID of the security group"
  value = "${aws_security_group.this.id}"
}

output "name" {
  description = "the name of the security group"
  value = "${aws_security_group.this.name}"
}

output "description" {
  description = "the description of the security group"
  value = "${aws_security_group.this.description}"
}

output "vpc_id" {
  description = "the VPC ID of the security group"
  value = "${aws_security_group.this.vpc_id}"
}
