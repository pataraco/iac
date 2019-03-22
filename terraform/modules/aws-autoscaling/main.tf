#######################
# Launch Template
#######################
resource "aws_launch_template" "launch_template" {
  name                                  = "${var.lt_name}"
    block_device_mappings               = {
    # device_name = "/dev/xvdb"
    device_name = "${var.ebs_dev_name_a}"
    ebs {
      volume_type                       = "${var.ebs_type_a}"
      volume_size                       = "${var.ebs_size_a}"
      # iops                              = "${var.ebs_iops_a}"
      encrypted                         = "${var.encryption_a}"
      kms_key_id                        = "${var.kms_key_id}"
    }
  }
    block_device_mappings               = {
    device_name = "${var.ebs_dev_name_b}"
    ebs {
      volume_type                       = "${var.ebs_type_b}"
      volume_size                       = "${var.ebs_size_b}"
      # iops                              = "${var.ebs_iops_b}"
      # encrypted                         = "${var.encryption_b}"
      # kms_key_id                        = "${var.kms_key_id}"
    }
  }  
  ebs_optimized                         = "${var.ebs_optimized}"
  image_id                              = "${var.image_id}"
  instance_type                         = "${var.instance_type}"
  vpc_security_group_ids                = ["${var.security_groups}"]
  iam_instance_profile { name           = "${var.iam_instance_profile}"
  }
  monitoring { enabled                  = "${var.enable_monitoring}"
  }
  key_name                              = "${var.key_name}"
  user_data                             = "${base64encode(var.user_data)}"
  #elastic_gpu_specifications {type = "test"}
  #capacity_reservation_specification {capacity_reservation_preference = "open"}
  #credit_specification {cpu_credits = "standard"}
  #disable_api_termination = true
  #instance_initiated_shutdown_behavior = "terminate"
  #instance_market_options {market_type = "spot"}
  #kernel_id = "test"
  #license_specification {license_configuration_arn = "arn:aws:license-manager:eu-west-1:123456789012:license-configuration:lic-0123456789abcdef0123456789abcdef"  }
  #network_interfaces {associate_public_ip_address = true}
  #placement {availability_zone = "us-west-2a"}
  #ram_disk_id = "test"
  # tag_specifications {
  #   resource_type = "instance"
  tags                                   = "${merge(map("Name", var.lt_name), map("Env", var.env), var.tags_lt)}"

  }

####################
# Autoscaling group
####################
resource "aws_autoscaling_group" "asg_main" {
  name_prefix           = "${var.asg_name}-"
  launch_template {id   = "${aws_launch_template.launch_template.id}"
  version = "$$Latest"
}
  vpc_zone_identifier  = ["${var.vpc_zone_identifier}"]
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"

  load_balancers            = ["${var.load_balancers}"]
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"

  min_elb_capacity          = "${var.min_elb_capacity}"
  wait_for_elb_capacity     = "${var.wait_for_elb_capacity}"
  target_group_arns         = ["${var.target_group_arns}"]
  default_cooldown          = "${var.default_cooldown}"
  force_delete              = "${var.force_delete}"
  termination_policies      = "${var.termination_policies}"
  suspended_processes       = "${var.suspended_processes}"
  placement_group           = "${var.placement_group}"
  enabled_metrics           = ["${var.enabled_metrics}"]
  metrics_granularity       = "${var.metrics_granularity}"
  wait_for_capacity_timeout = "${var.wait_for_capacity_timeout}"
  protect_from_scale_in     = "${var.protect_from_scale_in}"

  tags = ["${concat(
      list(map("key", "Name", "value", var.asg_name, "propagate_at_launch", true)),
      var.tags,
      local.tags_asg_format
   )}"]

  lifecycle {
    create_before_destroy = true
  }
}

# ################################################
# # Autoscaling group with initial lifecycle hook
# ################################################
# resource "aws_autoscaling_group" "asg_with_initial_lifecycle_hook" {
#   count = "${var.create_asg && var.create_asg_with_initial_lifecycle_hook ? 1 : 0}"

#   name_prefix          = "${join("-", compact(list(coalesce(var.asg_name, var.name), var.recreate_asg_when_lc_changes ? element(concat(random_pet.asg_name.*.id, list("")), 0) : "")))}-"
#   launch_configuration = "${var.create_lc ? element(aws_launch_configuration.launch_config.*.name, 0) : var.launch_configuration}"
#   vpc_zone_identifier  = ["${var.vpc_zone_identifier}"]
#   max_size             = "${var.max_size}"
#   min_size             = "${var.min_size}"
#   desired_capacity     = "${var.desired_capacity}"

#   load_balancers            = ["${var.load_balancers}"]
#   health_check_grace_period = "${var.health_check_grace_period}"
#   health_check_type         = "${var.health_check_type}"

#   min_elb_capacity          = "${var.min_elb_capacity}"
#   wait_for_elb_capacity     = "${var.wait_for_elb_capacity}"
#   target_group_arns         = ["${var.target_group_arns}"]
#   default_cooldown          = "${var.default_cooldown}"
#   force_delete              = "${var.force_delete}"
#   termination_policies      = "${var.termination_policies}"
#   suspended_processes       = "${var.suspended_processes}"
#   placement_group           = "${var.placement_group}"
#   enabled_metrics           = ["${var.enabled_metrics}"]
#   metrics_granularity       = "${var.metrics_granularity}"
#   wait_for_capacity_timeout = "${var.wait_for_capacity_timeout}"
#   protect_from_scale_in     = "${var.protect_from_scale_in}"

#   initial_lifecycle_hook {
#     name                    = "${var.initial_lifecycle_hook_name}"
#     lifecycle_transition    = "${var.initial_lifecycle_hook_lifecycle_transition}"
#     notification_metadata   = "${var.initial_lifecycle_hook_notification_metadata}"
#     heartbeat_timeout       = "${var.initial_lifecycle_hook_heartbeat_timeout}"
#     notification_target_arn = "${var.initial_lifecycle_hook_notification_target_arn}"
#     role_arn                = "${var.initial_lifecycle_hook_role_arn}"
#     default_result          = "${var.initial_lifecycle_hook_default_result}"
#   }

#   tags = ["${concat(
#       list(map("key", "Name", "value", var.asg_name, "propagate_at_launch", true)),
#       var.tags,
#       local.tags_asg_format
#    )}"]

#   lifecycle {
#     create_before_destroy = true
#   }
# }
