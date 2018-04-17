#!/usr/bin/env python
"""Stacker module for creating an Auto Scaling Launch Configuration."""

from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import (
    CFNString, EC2SecurityGroupIdList
)
from troposphere import (
    autoscaling, Base64, ec2, FindInMap, Join, Output, Ref, Tags, Sub
)
from utils import standalone_output  # pylint: disable=relative-import


class LaunchConfiguration(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'AssociatePublicIpAddress': {
            'type': CFNString,
            'description': 'Indicates whether instances in the Auto Scaling'
                           ' group receive public IP addresses or not'
                           ' (default: false)',
            'allowed_values': ['false', 'true'],
            'constraint_description': 'enter true or false',
            'default': 'false',
        },
        'EcsClusterName': {
            'type': CFNString,
            'description': 'The name of the ECS Cluster to have the ECS'
                           ' Instance attach to',
        },
        'ImageId': {
            'type': CFNString,
            'description': 'The AMI image ID of an ECS instance'
                           ' recommended by AWS. This value obtained by a'
                           ' look up in SSM (/aws/service/ecs/optimized-ami'
                           '/amazon-linux/recommended)',
        },
        'InstanceProfile': {
            'type': CFNString,
            'description': 'The name or the Amazon Resource Name (ARN) of the'
                           ' instance profile associated with the IAM role for'
                           ' the instance. The instance profile contains the'
                           ' IAM role',
            'allowed_pattern': '[a-zA-Z0-9-:/]*',
        },
        'InstanceType': {
            'type': CFNString,
            'description': 'Specifies the instance type of the EC2 instance'
                           ' (default: t2.micro)',
            'default': 't2.micro',
        },
        'KeyName': {
            'type': CFNString,
            'description': 'Provides the name of the EC2 key pair',
        },
        'PlacementTenancy': {
            'type': CFNString,
            'description': 'The tenancy of the instance: dedicated or default'
                           ' (default: default)',
            'allowed_values': ['dedicated', 'default'],
            'default': 'default',
        },
        'SecurityGroups': {
            'type': EC2SecurityGroupIdList,
            'description': 'A list that contains the EC2 security groups to'
                           ' assign to the Amazon EC2 instances in the Auto'
                           ' Scaling group'
        },
    }

    def add_mappings(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        template.add_mapping(
            'EcsAmiRegionMap', {
                'us-east-2' : { 'AMI' : 'ami-1b90a67e'},
                'us-east-1' : { 'AMI' : 'ami-cb17d8b6'},
                'us-west-2' : { 'AMI' : 'ami-05b5277d'},
                'us-west-1' : { 'AMI' : 'ami-9cbbaffc'},
                'eu-west-3' : { 'AMI' : 'ami-914afcec'},
                'eu-west-2' : { 'AMI' : 'ami-a48d6bc3'},
                'eu-west-1' : { 'AMI' : 'ami-bfb5fec6'},
                'eu-central-1' : { 'AMI' : 'ami-ac055447'},
                'ap-northeast-2' : { 'AMI' : 'ami-ba74d8d4'},
                'ap-northeast-1' : { 'AMI' : 'ami-5add893c'},
                'ap-southeast-2' : { 'AMI' : 'ami-4cc5072e'},
                'ap-southeast-1' : { 'AMI' : 'ami-acbcefd0'},
                'ca-central-1' : { 'AMI' : 'ami-a535b2c1'},
                'ap-south-1' : { 'AMI' : 'ami-2149114e'},
                'sa-east-1' : { 'AMI' : 'ami-d3bce9bf'},
            }
        )

    def add_resources_and_outputs(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        autoscalinglaunchconfiguration = template.add_resource(
            autoscaling.LaunchConfiguration(
                'AutoScalingLaunchConfiguration',
                BlockDeviceMappings=[ec2.BlockDeviceMapping(
                    DeviceName='/dev/sda1',
                    Ebs=ec2.EBSBlockDevice(
                        VolumeSize=100
                    )
                )],
                AssociatePublicIpAddress=variables[
                    'AssociatePublicIpAddress'
                ].ref,
                IamInstanceProfile=variables['InstanceProfile'].ref,
                #ImageId=FindInMap(
                #    'EcsAmiRegionMap', Ref('AWS::Region'), 'AMI'
                #),
                ImageId=variables['ImageId'].ref,
                InstanceType=variables['InstanceType'].ref,
                KeyName=variables['KeyName'].ref,
                PlacementTenancy=variables['PlacementTenancy'].ref,
                SecurityGroups=variables['SecurityGroups'].ref,
                UserData=Base64(Join('', [
                    '#!/bin/bash\n',
                    '\n',
                    'echo ECS_CLUSTER=',
                    variables['EcsClusterName'].ref,
                    ' >> /etc/ecs/ecs.config\n',
                ]))
            )
        )

        template.add_output(
            Output(
                "{}Name".format(autoscalinglaunchconfiguration.title),
                Description="Name of the Auto Scaling Launch Configuration",
                Value=Ref(autoscalinglaunchconfiguration)
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an Auto Scaling Launch Configuration'
        )
        self.add_mappings()
        self.add_resources_and_outputs()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=LaunchConfiguration(
            'test', Context({"namespace": "test"}), None
        )
    )
