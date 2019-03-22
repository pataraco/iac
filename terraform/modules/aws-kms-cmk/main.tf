# Creates KMS CMKs


# Resources #

resource "aws_kms_alias" "this" {
  count = "${var.alias != "" ? 1 : 0}"
  name = "alias/${var.alias}"
  target_key_id = "${aws_kms_key.this.key_id}"
}

resource "aws_kms_key" "this" {
  deletion_window_in_days = "${var.deletion_window_in_days}"
  description = "${var.description}"
  enable_key_rotation = "${var.enable_key_rotation}"
  is_enabled = "${var.is_enabled}"
  policy = "${var.policy}"
  tags = "${merge(map("Name", var.alias), var.tags)}"
}
