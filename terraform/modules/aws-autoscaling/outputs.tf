locals {
 
  autoscaling_group_id                        = "${element(concat(coalescelist(aws_autoscaling_group.asg_main.*.id, aws_autoscaling_group.asg_main_with_initial_lifecycle_hook.*.id), list("")), 0)}"
  autoscaling_group_name                      = "${element(concat(coalescelist(aws_autoscaling_group.asg_main.*.name, aws_autoscaling_group.asg_main_with_initial_lifecycle_hook.*.name), list("")), 0)}"
  autoscaling_group_arn                       = "${element(concat(coalescelist(aws_autoscaling_group.asg_main.*.arn, aws_autoscaling_group.asg_main_with_initial_lifecycle_hook.*.arn), list("")), 0)}"
  autoscaling_group_min_size                  = "${element(concat(coalescelist(aws_autoscaling_group.asg_main.*.min_size, aws_autoscaling_group.asg_main_with_initial_lifecycle_hook.*.min_size), list("")), 0)}"
  autoscaling_group_max_size                  = "${element(concat(coalescelist(aws_autoscaling_group.asg_main.*.max_size, aws_autoscaling_group.asg_main_with_initial_lifecycle_hook.*.max_size), list("")), 0)}"
  autoscaling_group_desired_capacity          = "${element(concat(coalescelist(aws_autoscaling_group.asg_main.*.desired_capacity, aws_autoscaling_group.asg_main_with_initial_lifecycle_hook.*.desired_capacity), list("")), 0)}"
  autoscaling_group_default_cooldown          = "${element(concat(coalescelist(aws_autoscaling_group.asg_main.*.default_cooldown, aws_autoscaling_group.asg_main_with_initial_lifecycle_hook.*.default_cooldown), list("")), 0)}"
  autoscaling_group_health_check_grace_period = "${element(concat(coalescelist(aws_autoscaling_group.asg_main.*.health_check_grace_period, aws_autoscaling_group.asg_main_with_initial_lifecycle_hook.*.health_check_grace_period), list("")), 0)}"
  autoscaling_group_health_check_type         = "${element(concat(coalescelist(aws_autoscaling_group.asg_main.*.health_check_type, aws_autoscaling_group.asg_main_with_initial_lifecycle_hook.*.health_check_type), list("")), 0)}"
}

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = "${local.autoscaling_group_id}"
}

output "autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = "${local.autoscaling_group_name}"
}

output "autoscaling_group_arn" {
  description = "The ARN for AutoScaling Group"
  value       = "${local.autoscaling_group_arn}"
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the autoscale group"
  value       = "${local.autoscaling_group_min_size}"
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the autoscale group"
  value       = "${local.autoscaling_group_max_size}"
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = "${local.autoscaling_group_desired_capacity}"
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = "${local.autoscaling_group_default_cooldown}"
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = "${local.autoscaling_group_health_check_grace_period}"
}

output "autoscaling_group_health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done"
  value       = "${local.autoscaling_group_health_check_type}"
}


//output "this_autoscaling_group_vpc_zone_identifier" {
//  description = "The VPC zone identifier"
//  value       = "${element(concat(aws_autoscaling_group.this.vpc_zone_identifier, list("")), 0)}"
//}
//
//output "this_autoscaling_group_load_balancers" {
//  description = "The load balancer names associated with the autoscaling group"
//  value       = "${aws_autoscaling_group.this.load_balancers}"
//}
//
//output "this_autoscaling_group_target_group_arns" {
//  description = "List of Target Group ARNs that apply to this AutoScaling Group"
//  value       = "${aws_autoscaling_group.this.target_group_arns}"
//}

