# Module Variables

variable "iam_role_name" {
  description = "the name to give to the role"
}

variable "instance_profile_name" {
  description = "the name to give to the profile"
}

variable "iam_policy_name" {
  description = "the name to give to the policy"
}

variable "create_profile" {
  default = "false"
  description = "whether or not to create an instance profile of the role"
}

variable "description" {
  description = "the description to give to the role"
}

variable "path" {
  default = "/"
  description = "the path to place the role"
}

variable "policy" {
  description = "the policy statement (json) to give to the role"
}

variable "service" {
  description = "service that needs access to assume the role"
}

variable "tags" {
  description = "additional tags to tag the role with"
  type = "map"
}
