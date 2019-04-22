bucket         = "company-proj-nonprod-env-tf-states"
dynamodb_table = "company-proj-nonprod-env-tf-locks"
kms_key_id     = "arn:aws:kms:us-west-2:1234567890:key/????-????-????-????-????"
# role to assume when managing state files
# note: comment out when creating the actual role
role_arn       = "arn:aws:iam::1234567890:role/proj-nonprod-env-manage-tf-states"
