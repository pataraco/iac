bucket         = "company-proj-prod-env-global-tf-states"
dynamodb_table = "company-proj-prod-env-global-tf-locks"
kms_key_id     = "arn:aws:kms:us-west-2:1234567890:key/????-????-????-????-????"
# role to assume when managing state files
# note: comment out when creating the actual role
role_arn       = "arn:aws:iam::1234567890:role/proj-prod-env-tf-states"
