# Module Outputs

output "iam_role_name" {
  description = "The name of the IAM role created"
  value = "${aws_iam_role.iam_role.name}"
}

output "iam_role_arn" {
  description = "The ARN of the IAM role created"
  value = "${aws_iam_role.iam_role.arn}"
}

output "instance_profile_name" {
  description = "The name of the instance profile created"
  # value = "${aws_iam_instance_profile.this.name}"
  value = "${join("", aws_iam_instance_profile.iam_instance_profile.*.name)}"
}

output "instance_profile_arn" {
  description = "The ARN of the instance profile created"
  # value = "${aws_iam_instance_profile.this.arn}"
  value = "${join("", aws_iam_instance_profile.iam_instance_profile.*.arn)}"
}
