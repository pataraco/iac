resource "aws_security_group" "this" {
  name = "${var.name}"
  description = "${var.description}"
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "${var.name}"
    Env = "${var.env}"
  }
}


# egress rule too allow all egress

# this adds the default egress rule back that TF removes by default
resource "aws_security_group_rule" "egress_all" {
  from_port = 0
  to_port = 0
  protocol = "-1"
  description = "allow all egress"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.this.id}"
  type = "egress"
}


# ingress rules by CIDR's

resource "aws_security_group_rule" "ingress_cidrs_1" {
  count = "${length(var.cidr_blocks_1) != 0 ? 1 : 0}"
  from_port = "${var.from_to_proto_desc_cidrs_1[0]}"
  to_port = "${var.from_to_proto_desc_cidrs_1[1]}"
  protocol = "${var.from_to_proto_desc_cidrs_1[2]}"
  description = "${var.from_to_proto_desc_cidrs_1[3]}"
  self = "${var.self_cidrs_1}"
  cidr_blocks = "${var.cidr_blocks_1}"
  security_group_id = "${aws_security_group.this.id}"
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_cidrs_2" {
  count = "${length(var.cidr_blocks_2) != 0 ? 1 : 0}"
  from_port = "${var.from_to_proto_desc_cidrs_2[0]}"
  to_port = "${var.from_to_proto_desc_cidrs_2[1]}"
  protocol = "${var.from_to_proto_desc_cidrs_2[2]}"
  description = "${var.from_to_proto_desc_cidrs_2[3]}"
  self = "${var.self_cidrs_2}"
  cidr_blocks = "${var.cidr_blocks_2}"
  security_group_id = "${aws_security_group.this.id}"
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_cidrs_3" {
  count = "${length(var.cidr_blocks_3) != 0 ? 1 : 0}"
  from_port = "${var.from_to_proto_desc_cidrs_3[0]}"
  to_port = "${var.from_to_proto_desc_cidrs_3[1]}"
  protocol = "${var.from_to_proto_desc_cidrs_3[2]}"
  description = "${var.from_to_proto_desc_cidrs_3[3]}"
  self = "${var.self_cidrs_3}"
  cidr_blocks = "${var.cidr_blocks_3}"
  security_group_id = "${aws_security_group.this.id}"
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_cidrs_4" {
  count = "${length(var.cidr_blocks_4) != 0 ? 1 : 0}"
  from_port = "${var.from_to_proto_desc_cidrs_4[0]}"
  to_port = "${var.from_to_proto_desc_cidrs_4[1]}"
  protocol = "${var.from_to_proto_desc_cidrs_4[2]}"
  description = "${var.from_to_proto_desc_cidrs_4[3]}"
  self = "${var.self_cidrs_4}"
  cidr_blocks = "${var.cidr_blocks_4}"
  security_group_id = "${aws_security_group.this.id}"
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_cidrs_5" {
  count = "${length(var.cidr_blocks_5) != 0 ? 1 : 0}"
  from_port = "${var.from_to_proto_desc_cidrs_5[0]}"
  to_port = "${var.from_to_proto_desc_cidrs_5[1]}"
  protocol = "${var.from_to_proto_desc_cidrs_5[2]}"
  description = "${var.from_to_proto_desc_cidrs_5[3]}"
  self = "${var.self_cidrs_5}"
  cidr_blocks = "${var.cidr_blocks_5}"
  security_group_id = "${aws_security_group.this.id}"
  type = "ingress"
}


# ingress rules by Security Group ID's

resource "aws_security_group_rule" "ingress_sgid_1" {
  count = "${var.sgid_1 != "" ? 1 : 0}"
  from_port = "${var.from_to_proto_desc_sgid_1[0]}"
  to_port = "${var.from_to_proto_desc_sgid_1[1]}"
  protocol = "${var.from_to_proto_desc_sgid_1[2]}"
  description = "${var.from_to_proto_desc_sgid_1[3]}"
  source_security_group_id = "${var.sgid_1}"
  security_group_id = "${aws_security_group.this.id}"
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_sgid_2" {
  count = "${var.sgid_2 != "" ? 1 : 0}"
  from_port = "${var.from_to_proto_desc_sgid_2[0]}"
  to_port = "${var.from_to_proto_desc_sgid_2[1]}"
  protocol = "${var.from_to_proto_desc_sgid_2[2]}"
  description = "${var.from_to_proto_desc_sgid_2[3]}"
  source_security_group_id = "${var.sgid_2}"
  security_group_id = "${aws_security_group.this.id}"
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_sgid_3" {
  count = "${var.sgid_3 != "" ? 1 : 0}"
  from_port = "${var.from_to_proto_desc_sgid_3[0]}"
  to_port = "${var.from_to_proto_desc_sgid_3[1]}"
  protocol = "${var.from_to_proto_desc_sgid_3[2]}"
  description = "${var.from_to_proto_desc_sgid_3[3]}"
  source_security_group_id = "${var.sgid_3}"
  security_group_id = "${aws_security_group.this.id}"
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_sgid_4" {
  count = "${var.sgid_4 != "" ? 1 : 0}"
  from_port = "${var.from_to_proto_desc_sgid_4[0]}"
  to_port = "${var.from_to_proto_desc_sgid_4[1]}"
  protocol = "${var.from_to_proto_desc_sgid_4[2]}"
  description = "${var.from_to_proto_desc_sgid_4[3]}"
  source_security_group_id = "${var.sgid_4}"
  security_group_id = "${aws_security_group.this.id}"
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_sgid_5" {
  count = "${var.sgid_5 != "" ? 1 : 0}"
  from_port = "${var.from_to_proto_desc_sgid_5[0]}"
  to_port = "${var.from_to_proto_desc_sgid_5[1]}"
  protocol = "${var.from_to_proto_desc_sgid_5[2]}"
  description = "${var.from_to_proto_desc_sgid_5[3]}"
  source_security_group_id = "${var.sgid_5}"
  security_group_id = "${aws_security_group.this.id}"
  type = "ingress"
}
