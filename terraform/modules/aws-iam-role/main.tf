# Creates IAM Roles/Policies/Profiles for resources


# Data #

# render an EC2 assume role policy with passed "service" variable
data "template_file" "this_assume_role_policy" {
  template = "${file("${path.module}/templates/iam-policy-assume-role.json")}"
  vars {
    service = "${var.service}"
  }
}


# Resources #

resource "aws_iam_instance_profile" "iam_instance_profile" {
  count = "${var.create_profile == "true" ? 1 : 0}"
  name = "${var.instance_profile_name}"
  role = "${aws_iam_role.iam_role.name}"
}

resource "aws_iam_role" "iam_role" {
  name = "${var.iam_role_name}"
  description = "${var.description}"
  path = "${var.path}"
  assume_role_policy = "${data.template_file.this_assume_role_policy.rendered}"
  tags = "${merge(map("Name", var.iam_role_name), var.tags)}"
}

resource "aws_iam_role_policy" "iam_policy" {
  name = "${var.iam_policy_name}"
  role = "${aws_iam_role.iam_role.id}"
  policy = "${var.policy}"
}
