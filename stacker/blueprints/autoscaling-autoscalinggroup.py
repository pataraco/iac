#!/usr/bin/env python
"""Stacker module for creating an Auto Scaling Group."""

from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import (
    CFNNumber, CFNString, EC2SubnetIdList
)
from troposphere import (
    autoscaling, Base64, ec2, Join, Output, Ref
)
from troposphere.autoscaling import Tags
from utils import standalone_output  # pylint: disable=relative-import


class AutoScalingGroup(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'ApplicationName': {
            'type': CFNString,
            'description': 'Name of Application for tagging purposes',
        },
        'AutoScalingGroupName': {
            'type': CFNString,
            'description': 'Name to give AutoScaling Group',
        },
        'Cooldown': {
            'type': CFNNumber,
            'description': 'The number of seconds after a scaling activity is'
                           ' completed before any further scaling activities'
                           ' can start',
            'default': 300,
        },
        'DesiredCapacity': {
            'type': CFNNumber,
            'description': 'Number of desired instances to run',
            'default': 1,
        },
        'EnvironmentName': {
            'type': CFNString,
            'default': 'production',
            'description': 'Name of Environment for tagging purposes'
                           ' (default: production)',
        },
        'HealthCheckGracePeriod': {
            'type': CFNNumber,
            'description': 'The length of time in seconds after a new EC2'
                           ' instance comes into service that Auto Scaling'
                           ' starts checking its health',
            'default': 0,
        },
        'HealthCheckType': {
            'type': CFNString,
            'description': 'The service you want the health status from,'
                           ' Amazon EC2 or Elastic Load Balancer. Valid values'
                           ' are EC2 or ELB (default: EC2)',
            'allowed_values': ['EC2', 'ELB'],
            'default': 'EC2',
        },
        'InstanceName': {
            'type': CFNString,
            'description': 'Name to give Instance',
        },
        'LaunchConfigurationName': {
            'type': CFNString,
            'description': 'Specifies the Launch Configuration name',
        },
        'MaxSize': {
            'type': CFNNumber,
            'description': 'The maximum size of the Auto Scaling group',
            'default': 2,
        },
        'MinSize': {
            'type': CFNNumber,
            'description': 'The minimum size of the Auto Scaling group',
            'default': 1,
        },
        'SubnetIdList': {
            'type': EC2SubnetIdList,
            'description': 'A list subnets to place EC2 intances into'
                           ' (used for VPCZoneIdentifier parameter)',
        },
    }

    def add_resources_and_outputs(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        autoscalinggroup = template.add_resource(
            autoscaling.AutoScalingGroup(
                'AutoScalingGroup',
                # this doesn't work - even though it's in tropohere
                #                     and the AWS CloudFormation docs
                # error:
                #     AttributeError: AWS::AutoScaling::AutoScalingGroup
                #        object does not support attribute AutoScalingGroupName
                #AutoScalingGroupName=variables['AutoScalingGroupName'].ref,
                Cooldown=variables['Cooldown'].ref,
                DesiredCapacity=variables['DesiredCapacity'].ref,
                HealthCheckGracePeriod=variables['HealthCheckGracePeriod'].ref,
                HealthCheckType=variables['HealthCheckType'].ref,
                LaunchConfigurationName=variables[
                    'LaunchConfigurationName'
                ].ref,
                MaxSize=variables['MaxSize'].ref,
                MinSize=variables['MinSize'].ref,
                Tags=Tags(
                    Application=variables['ApplicationName'].ref,
                    Environment=variables['EnvironmentName'].ref,
                    Name=variables['InstanceName'].ref
                ),
                VPCZoneIdentifier=variables['SubnetIdList'].ref,
            )
        )

        template.add_output(
            Output(
                "{}Name".format(autoscalinggroup.title),
                Description="Name of the Auto Scaling Group",
                Value=Ref(autoscalinggroup)
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an Auto Scaling Group'
        )
        self.add_resources_and_outputs()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=AutoScalingGroup(
            'test', Context({"namespace": "test"}), None
        )
    )
