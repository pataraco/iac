resource "aws_route53_zone" "route53_zone_private" {
  count = 0
  name = "${var.r53_domain_name_private}"
  comment = "private root domain for ${var.application}-${var.env} (Terraform managed)"
  tags = "${merge(map("Name", var.r53_domain_name_private), var.additional_tags)}"
  vpc = {
    vpc_region = "${var.region}"
    vpc_id = "${var.vpc_id}"
  }
  lifecycle {
    ignore_changes = ["vpc"]
  }
}

resource "null_resource" "vpc_association_auth" {
  count = 0
  provisioner "local-exec" {
    command = "aws route53 create-vpc-association-authorization --hosted-zone-id \"${aws_route53_zone.route53_zone_private.zone_id}\" --vpc VPCRegion=\"${var.region}\",VPCId=\"${var.vpc_id_2}\""
  }
#   assume_role {
#     role_arn = "arn:aws:iam::123456789:role/app-env-deploy-role"
#   }
}

resource "aws_route53_zone_association" "secondary" {
  count = 1
  # zone_id = "${var.zone_id}"
  zone_id = "Z13DJQ0EMMSHNF"
  vpc_id  = "${var.vpc_id_2}"
}
