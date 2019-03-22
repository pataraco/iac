# Module Variables

variable "name" {
  description = "the name to give to the group/profile/policy"
}

variable "path" {
  default = "/"
  description = "the path to place the group"
}

variable "inline_policy" {
  default = ""
  description = "the in-line policy statement (json) to attach to the group"
}

variable "managed_policy_arn" {
  default = ""
  description = "the managed policy ARN to attach to the group"
}
