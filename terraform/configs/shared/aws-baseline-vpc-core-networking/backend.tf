# partial backend config
# remaining defined in {ssp,ssnp}-backend.tfvars
# used by wrapper script to configure the backend
terraform {
  required_version = ">= 0.12.24"
  # backend "s3" {
  #   region  = "us-west-2"
  #   encrypt = true
  # }
}
