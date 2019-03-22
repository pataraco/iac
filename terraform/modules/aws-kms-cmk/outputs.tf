# Module Outputs

output "kms_cmk_alias_arn" {
  description = "The ARN of the KMS CMK alias created"
  value = "${aws_kms_alias.this.*.arn}"
}

output "kms_cmk_alias_tki" {
  description = "The target key ID of the KMS CMK alias created"
  value = "${aws_kms_alias.this.*.target_key_arn}"
}

output "kms_cmk_key_arn" {
  description = "The ARN of the KMS CMK created"
  value = "${aws_kms_key.this.arn}"
}

output "kms_cmk_key_id" {
  description = "The ID of the KMS CMK created"
  value = "${aws_kms_key.this.id}"
}
