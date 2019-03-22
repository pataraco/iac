resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.bucket}"
  acl = "${var.acl}"
  versioning {
    enabled = "${var.versioning_enabled}"
    mfa_delete = "${var.versioning_mfa_delete}"
  }
  tags = "${merge(map("Name", var.bucket), var.tags)}"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  depends_on = ["aws_s3_bucket_policy.bucket_policy"]
  bucket = "${aws_s3_bucket.s3_bucket.id}"

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count = "${var.attach_bucket_policy}"
  bucket = "${aws_s3_bucket.s3_bucket.id}"
  policy = "${var.bucket_policy}"
}