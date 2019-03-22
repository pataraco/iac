resource "aws_instance" "ec2_instance" {
  depends_on = [ "aws_ebs_volume.ebs_e", "aws_ebs_volume.ebs_f", "aws_ebs_volume.ebs_g", "aws_ebs_volume.ebs_h", "aws_ebs_volume.ebs_t", "aws_ebs_volume.ebs_v" ]
  ami = "${var.ami}"
  disable_api_termination = "${var.disable_api_termination}"
  ebs_optimized = "${var.ebs_optimized}"
  get_password_data = "${var.get_password_data}"
  iam_instance_profile = "${var.iam_instance_profile}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  monitoring = "${var.monitoring}"
  network_interface {
    network_interface_id = "${aws_network_interface.network_interface.id}"
    device_index = 0
  }
  # private_ip = "${var.private_ip}"
  root_block_device = {
    delete_on_termination = "${var.root_block_device_delete_on_termination}"
    iops = "${var.root_block_device_iops}"
    volume_size = "${var.root_block_device_volume_size}"
    volume_type = "${var.root_block_device_volume_type}"
  }
  availability_zone = "${var.availability_zone}"
  tags = "${merge(map("Name", var.tags_name), map("Env", var.tags_env), var.tags_additional)}"
  user_data = "${var.user_data}"
  volume_tags = "${merge(map("Name", var.tags_name), map("Env", var.tags_env), var.tags_additional)}"
}

resource "aws_network_interface" "network_interface" {
  subnet_id       = "${var.subnet_id}"
  private_ips     = ["${var.private_ips}"]
  security_groups = ["${var.vpc_security_group_ids}"]
  tags            = "${merge(map("Name", var.tags_name), map("Env", var.tags_env), var.tags_additional)}"
}

resource "aws_ebs_volume" "ebs_b" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.ebs_block_device_volume_size_b}"
  encrypted         = "${var.ebs_encryption}"
  kms_key_id        = "${var.ebs_kms_key_id}"
  iops              = "${var.ebs_block_device_iops_b}"
  type              = "${var.ebs_block_device_volume_type_b}"
  tags = "${merge(map("Name", var.tags_name), map("Env", var.tags_env), var.tags_additional)}"
  count           = "${var.create_backup_drive}"
}

resource "aws_volume_attachment" "ebs_b" {
  device_name = "${var.ebs_block_device_name_b}"
  volume_id   = "${aws_ebs_volume.ebs_b.id}"
  instance_id = "${aws_instance.ec2_instance.id}"
  count           = "${var.create_backup_drive}"
}

resource "aws_ebs_volume" "ebs_e" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.ebs_block_device_volume_size_e}"
  encrypted         = "${var.ebs_encryption}"
  kms_key_id        = "${var.ebs_kms_key_id}"
  iops              = "${var.ebs_block_device_iops_e}"
  type              = "${var.ebs_block_device_volume_type_e}"
  tags = "${merge(map("Name", var.tags_name), map("Env", var.tags_env), var.tags_additional)}"
}

resource "aws_volume_attachment" "ebs_e" {
  device_name = "${var.ebs_block_device_name_e}"
  volume_id   = "${aws_ebs_volume.ebs_e.id}"
  instance_id = "${aws_instance.ec2_instance.id}"
}

resource "aws_ebs_volume" "ebs_f" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.ebs_block_device_volume_size_f}"
  encrypted         = "${var.ebs_encryption}"
  kms_key_id        = "${var.ebs_kms_key_id}"
  iops              = "${var.ebs_block_device_iops_f}"
  type              = "${var.ebs_block_device_volume_type_f}"
  tags = "${merge(map("Name", var.tags_name), map("Env", var.tags_env), var.tags_additional)}"
}

resource "aws_volume_attachment" "ebs_f" {
  device_name = "${var.ebs_block_device_name_f}"
  volume_id   = "${aws_ebs_volume.ebs_f.id}"
  instance_id = "${aws_instance.ec2_instance.id}"
}

resource "aws_ebs_volume" "ebs_g" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.ebs_block_device_volume_size_g}"
  encrypted         = "${var.ebs_encryption}"
  kms_key_id        = "${var.ebs_kms_key_id}"
  iops              = "${var.ebs_block_device_iops_g}"
  type              = "${var.ebs_block_device_volume_type_g}"
  tags = "${merge(map("Name", var.tags_name), map("Env", var.tags_env), var.tags_additional)}"
}

resource "aws_volume_attachment" "ebs_g" {
  device_name = "${var.ebs_block_device_name_g}"
  volume_id   = "${aws_ebs_volume.ebs_g.id}"
  instance_id = "${aws_instance.ec2_instance.id}"
}

resource "aws_ebs_volume" "ebs_h" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.ebs_block_device_volume_size_h}"
  encrypted         = "${var.ebs_encryption}"
  kms_key_id        = "${var.ebs_kms_key_id}"
  iops              = "${var.ebs_block_device_iops_h}"
  type              = "${var.ebs_block_device_volume_type_h}"
  tags = "${merge(map("Name", var.tags_name), map("Env", var.tags_env), var.tags_additional)}"
}

resource "aws_volume_attachment" "ebs_h" {
  device_name = "${var.ebs_block_device_name_h}"
  volume_id   = "${aws_ebs_volume.ebs_h.id}"
  instance_id = "${aws_instance.ec2_instance.id}"
}

resource "aws_ebs_volume" "ebs_t" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.ebs_block_device_volume_size_t}"
  encrypted         = "${var.ebs_encryption}"
  kms_key_id        = "${var.ebs_kms_key_id}"
  iops              = "${var.ebs_block_device_iops_t}"
  type              = "${var.ebs_block_device_volume_type_t}"
  tags = "${merge(map("Name", var.tags_name), map("Env", var.tags_env), var.tags_additional)}"
}

resource "aws_volume_attachment" "ebs_t" {
  device_name = "${var.ebs_block_device_name_t}"
  volume_id   = "${aws_ebs_volume.ebs_t.id}"
  instance_id = "${aws_instance.ec2_instance.id}"
}


resource "aws_ebs_volume" "ebs_v" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.ebs_block_device_volume_size_v}"
  encrypted         = "${var.ebs_encryption}"
  kms_key_id        = "${var.ebs_kms_key_id}"
  iops              = "${var.ebs_block_device_iops_v}"
  type              = "${var.ebs_block_device_volume_type_v}"
  tags = "${merge(map("Name", var.tags_name), map("Env", var.tags_env), var.tags_additional)}"
}

resource "aws_volume_attachment" "ebs_v" {
  device_name = "${var.ebs_block_device_name_v}"
  volume_id   = "${aws_ebs_volume.ebs_v.id}"
  instance_id = "${aws_instance.ec2_instance.id}"
}
