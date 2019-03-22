# Module Outputs

output "iam_group_name" {
  description = "The name of the IAM group created"
  value = "${aws_iam_group.this.name}"
}

output "iam_group_arn" {
  description = "The ARN of the IAM group created"
  value = "${aws_iam_group.this.arn}"
}
