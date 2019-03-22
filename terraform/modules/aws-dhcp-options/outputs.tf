output "dhcp_options_id" {
  description = "The dhcp opption id"
  value       = "${aws_vpc_dhcp_options.dhcp_options.id}"
}

