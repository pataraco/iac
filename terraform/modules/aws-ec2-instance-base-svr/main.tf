resource "aws_instance" "ec2_instance" {
  ami = "${var.ami}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  disable_api_termination = "${var.disable_api_termination}"
  ebs_optimized = "${var.ebs_optimized}"
  iam_instance_profile = "${var.iam_instance_profile}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  monitoring = "${var.monitoring}"
  root_block_device = {
    delete_on_termination = "${var.root_block_device_delete_on_termination}"
    iops = "${var.root_block_device_iops}"
    volume_size = "${var.root_block_device_volume_size}"
    volume_type = "${var.root_block_device_volume_type}"
  }
  # ebs_block_device = {
  #   delete_on_termination = "${var.ebs_block_device_delete_on_termination_e}"
  #   device_name = "${var.ebs_block_device_name_e}"
  #   encrypted = "${var.ebs_block_device_encrypted_e}"
  #   iops = "${var.ebs_block_device_iops_e}"
  #   volume_size = "${var.ebs_block_device_volume_size_e}"
  #   volume_type = "${var.ebs_block_device_volume_type_e}"
  # }
  # ebs_block_device = {
  #   delete_on_termination = "${var.ebs_block_device_delete_on_termination_l}"
  #   device_name = "${var.ebs_block_device_name_l}"
  #   encrypted = "${var.ebs_block_device_encrypted_l}"
  #   iops = "${var.ebs_block_device_iops_l}"
  #   volume_size = "${var.ebs_block_device_volume_size_l}"
  #   volume_type = "${var.ebs_block_device_volume_type_l}"
  # }
  subnet_id = "${var.subnet_id}"
  tags = "${merge(map("Name", var.instance_count > 1 ? format("%s-%d", var.tags_name, count.index+1) : var.tags_name), map("Env", var.tags_env), var.tags_additional)}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  # user_data = "${data.template_file.user_data.rendered}"
  user_data = "${var.user_data}"
  volume_tags = "${merge(map("Name", var.instance_count > 1 ? format("%s-%d", var.tags_name, count.index+1) : var.tags_name), map("Env", var.tags_env), var.tags_additional)}"
}

resource "aws_ebs_volume" "ebs_e" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.ebs_block_device_volume_size_e}"
  encrypted         = "${var.ebs_block_device_encrypted_e}"
  kms_key_id        = "${var.ebs_kms_key_id}"
  iops              = "${var.ebs_block_device_iops_e}"
  type              = "${var.ebs_block_device_volume_type_e}"
  tags              = "${merge(map("Name", var.tags_name), map("Env", var.tags_env), var.tags_additional)}"
  count             = "${var.create_e_drive}" 
}

resource "aws_volume_attachment" "ebs_e" {
  device_name = "${var.ebs_block_device_name_e}"
  volume_id   = "${aws_ebs_volume.ebs_e.id}"
  instance_id = "${aws_instance.ec2_instance.id}"
  count       = "${var.create_e_drive}"
}

resource "aws_ebs_volume" "ebs_l" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.ebs_block_device_volume_size_l}"
  encrypted         = "${var.ebs_block_device_encrypted_l}"
  kms_key_id        = "${var.ebs_kms_key_id}"
  iops              = "${var.ebs_block_device_iops_l}"
  type              = "${var.ebs_block_device_volume_type_l}"
  tags = "${merge(map("Name", var.tags_name), map("Env", var.tags_env), var.tags_additional)}"
  count             = "${var.create_l_drive}"
}

resource "aws_volume_attachment" "ebs_l" {
  device_name = "${var.ebs_block_device_name_l}"
  volume_id   = "${aws_ebs_volume.ebs_l.id}"
  instance_id = "${aws_instance.ec2_instance.id}"
  count       = "${var.create_l_drive}"
}