data "aws_caller_identity" "current" {}


# Local Variables #

locals {
  tags = merge({ Environment : var.environment }, { Tier : var.tier }, var.tags)
}

resource "aws_vpc" "main" {
  cidr_block       = var.cidr
  instance_tenancy = "default"
  tags             = local.tags
}
