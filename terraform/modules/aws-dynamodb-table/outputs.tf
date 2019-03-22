output "arn" {
  description = "the ARN of the table"
  value = "${aws_dynamodb_table.dynamodb_table.arn}"
}

output "name" {
  description = "the name of the table"
  value = "${aws_dynamodb_table.dynamodb_table.id}"
}
