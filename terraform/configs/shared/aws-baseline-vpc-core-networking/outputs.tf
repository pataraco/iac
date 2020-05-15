# # Common Outputs

output "environment" {
  description = "The name of the Environment"
  value       = "${var.environment}"
}

output "region" {
  description = "The name of the Region"
  value       = "${var.region}"
}

output "id" {
  value = "aws_vpc.main.id"
}

output "owner_id" {
  value = "aws_vpc.main.owner_id"
}
