variable "acl" {
  default = "private"
  description = "ACL to give bucket (default: private)"
  type = "string"
}

variable "bucket" {
  description = "Name of bucket to create"
  type = "string"
}

variable "region" {
  default = "us-west-2"
  description = "Region to launch resources in"
  type = "string"
}

variable "tags" {
  default = {}
  description = "tags to give the S3 bucket"
  type = "map"
}

variable "versioning_enabled" {
  default = false
  description = "whether or not to enable versioning (default: false)"
  type = "string"
}

variable "versioning_mfa_delete" {
  default = false
  description = "enable MFA deletion protection (default: false)"
  type = "string"
}

variable "kms_key_arn" {
  description = "KMS key ARN to encrypt S3 objects"
  type = "string"
}

variable "attach_bucket_policy" {
  default = false
  description = "Attach bucket policy (default: false)"
  type = "string"
}

variable "bucket_policy" {
  default = ""
  description = "Bucket Policy"
  type = "string"
}