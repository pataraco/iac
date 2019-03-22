resource "aws_dynamodb_table" "dynamodb_table" {
  name = "${var.name}"
  billing_mode = "${var.billing_mode}"
  read_capacity = "${var.read_capacity}"
  write_capacity = "${var.write_capacity}"
  hash_key = "${var.hash_key}"
  server_side_encryption {
    enabled = "${var.encryption}"
  }
  attribute {
    name = "${var.hash_key}"
    type = "S"
  }

  tags = {
    Name = "${var.name}"
    Env = "${var.env}"
    # for future use
    # tags = "${merge(map("Name", var.name), map("Env", var.env), var.tags)}"
  }
}
