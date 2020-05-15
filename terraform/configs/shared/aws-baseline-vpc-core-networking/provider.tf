provider "aws" {
  region  = var.region
  version = "~> 2.0"
  # assume_role {
  #   role_arn = "arn:aws:iam::${lookup(var.aws_acct_ids, var.env)}:role/raco-${var.env}-deploy-devops"
  #   # session_name = "Terraform Deploy"     # not needed
  #   # external_id  = "EXTERNAL_ID"          # not needed
  # }
}
