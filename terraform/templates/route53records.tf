variable "domain_name_private" {
  default = "private.example.com"
}

variable "tiers" {
  default = {
    "0" = "common"
    "1" = "partner"
    "2" = "token"
  }
}

variable "r53_names" {
  # tier: name
  default = {
    "common" = "com"
    "partner" = "prt"
    "token" = "tkn"
  }
}

data "aws_route53_zone" "private" {
  name = "${var.env}.${var.domain_name_private}"
  vpc_id = "${module.datasource.aws_vpc_id}"
  private_zone = true
}

data "aws_lb" "albs" {
  count = "${length(var.r53_names)}"
  name = "${var.app}-${var.env}-${var.tiers[count.index]}"
}

resource "aws_route53_record" "albs" {
  count = "${length(var.r53_names)}"
  zone_id = "${data.aws_route53_zone.private.zone_id}"
  name = "${lookup(var.r53_names, var.tiers[count.index])}.${var.env}.${var.domain_name_private}"
  type = "CNAME"
  ttl = "300"
  records = ["${data.aws_lb.albs.*.dns_name[count.index]}"]
}
