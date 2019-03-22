resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name          = "${var.domain_name_private}"
  domain_name_servers  = ["${var.domain_name_server_a}", "${var.domain_name_server_b}"]
  ntp_servers          = ["${var.domain_name_server_a}"]
  netbios_name_servers = ["${var.domain_name_server_a}"]
  netbios_node_type    = 2

  tags = "${merge(map("Name", var.domain_name_private), var.additional_tags)}"
  
}

resource "aws_vpc_dhcp_options_association" "dhcp_option_association" {
  vpc_id          = "${var.vpc_id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dhcp_options.id}"
  count           = "${var.associate_dhcp_with_vpc}"
}




