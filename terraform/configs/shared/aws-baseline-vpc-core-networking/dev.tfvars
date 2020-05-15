# Common Settings
project  = "testing"
region   = "us-west-2"
vpc_name = "testing"

cidr = "10.0.0.0/24"

# Tag Settings

environment = "dev"
tier        = "shared"
tags = {
  Environment = "dev"
  Project     = "testing"
  Tier        = "shared"
}
