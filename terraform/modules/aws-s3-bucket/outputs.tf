output "arn" {
  description = "the ARN of the bucket created"
  value = "${aws_s3_bucket.s3_bucket.arn}"
}

output "dns" {
  description = "the DNS domain name of the bucket created"
  value = "${aws_s3_bucket.s3_bucket.bucket_domain_name}"
}

output "name" {
  description = "the Name of the bucket created"
  value = "${aws_s3_bucket.s3_bucket.id}"
}
