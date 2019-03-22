# Module Variables

variable "alias" {
  default = ""
  description = "the alias to give to the KMS CMK (optional)"
}

variable "deletion_window_in_days" {
  default = "30"
  description = "Duration (days) after which the key is deleted after destruction of the resource. (valid range: 7 - 30. default: 30)"
}

variable "description" {
  description = "the description to give to the KMS CMK"
}

variable "enable_key_rotation" {
  default = "false"
  description = "specifies whether key rotation is enabled (default: false)"
}

variable "policy" {
  description = "the key policy statement (json) to attach to the key"
}

variable "is_enabled" {
  default = "true"
  description = "specifies whether the KMS CMK is enabled (default: true)"
}

variable "tags" {
  description = "additional tags to tag the KMS CMK with"
  type = "map"
}
