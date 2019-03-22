# Creates IAM Groups/Policies for users


# Resources #

resource "aws_iam_group" "this" {
  name = "${var.name}"
  path = "${var.path}"
}

resource "aws_iam_group_policy" "this" {
  count = "${var.inline_policy != "" ? 1 : 0}"
  name = "${var.name}"
  group = "${aws_iam_group.this.id}"
  policy = "${var.inline_policy}"
}

resource "aws_iam_group_policy_attachment" "this" {
  count = "${var.managed_policy_arn != "" ? 1 : 0}"
  group      = "${aws_iam_group.this.name}"
  policy_arn = "${var.managed_policy_arn}"
}
