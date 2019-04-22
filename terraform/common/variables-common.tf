variable "app" {
  description = "Application stack name [set by wrapper]"
}

variable "aws_acct_ids" {
  default = {
    dev   = "1234567890"
    stag  = "5678901234"
    prod  = "3456789012"
    qa    = "7890123456"
    ssnp  = "9012345678"
    sspd  = "1098765432"
  }
  description = "Map of AWS account IDs"
  type = "map"
}

variable "colorstack" {
  description = "Colorstack color (blue|green|shared) [set by wrapper]"
}

variable "deploy" {
  default = ""
  description = "Deploy to launch (b|g|s for blue, green or shared) [set by wrapper]"
}

variable "env" {
  description = "Enviroment Name (lowercase) [set by wrapper]"
}

variable "environment" {
  description = "Enviroment Name (uppercase) [set by wrapper]"
}

variable "project" {
  default = ""
  description = "Project Name"
}

variable "region" {
  description = "The region to use [set by wrapper]"
}
