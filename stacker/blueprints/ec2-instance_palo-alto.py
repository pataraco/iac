#!/usr/bin/env python
"""Stacker module for creating a Palo Alto AWS EC2 Instance."""

from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString
from troposphere import (
    ec2, Export, FindInMap, Output, Ref, Tags, Sub
)
from utils import standalone_output  # pylint: disable=relative-import


class Instance(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'DetailedMonitoring': {
            'type': CFNString,
            'description': 'Whether or not to enable detailed monitoring'
                           ' (default: false)',
            'allowed_values': ['false', 'true'],
            'default': 'false',
        },
        # s4f # save for future use
        # s4f # 'InstanceProfile': {
        # s4f #     'type': CFNString,
        # s4f #     'description': 'The name or the Amazon Resource Name (ARN)'
        # s4f #                    ' of the instance profile associated with'
        # s4f #                    ' the IAM role for the instance. The'
        # s4f #                    ' instance profile contains the IAM role',
        # s4f #     'allowed_pattern': '[a-zA-Z0-9-:/]*',
        # s4f # },
        'InstanceType': {
            'type': CFNString,
            'description': 'Specifies the instance type of the EC2 instance'
                           ' (default: m4.xlarge - Palo Alto recommended)',
            'default': 'm4.xlarge',
        },
        'KeyName': {
            'type': CFNString,
            'description': 'Provides the name of the EC2 key pair',
        },
        'NetworkInterfaces': {
            'type': dict,
            'description': 'List of network interfaces to attach to the'
                           ' instance. Should be a dict of device indices and'
                           ' network interface ids',
            'default': {'0': 'eni-12345', '1': 'eni-67890'}
        },
        'PlacementTenancy': {
            'type': CFNString,
            'description': 'The tenancy of the instance:'
                           ' default, dedicated or host (default: default)',
            'allowed_values': ['default', 'dedicated', 'host'],
            'default': 'default',
        },
        'Tags': {
            'type': dict,
            'description': 'List of tags to add to the target group.'
                           ' Should be a dict of key:value pairs',
            'default': {'Name': 'TestName', 'App': 'TestApp',
                        'Env': 'TestEnv'},
        },
    }

    def add_mappings(self):
        """Add resources to template."""
        template = self.template

        template.add_mapping(
            'PaAmiRegionMap', {
                'us-east-1'     : {'AMI': 'ami-a2fa3bdf'},  # (N. Virginia)
                'us-east-2'     : {'AMI': 'ami-11e1d774'},  # (Ohio)
                'us-west-1'     : {'AMI': 'ami-a95b4fc9'},  # (N. California)
                'us-west-2'     : {'AMI': 'ami-d424b5ac'},  # (Oregon)
                # 'eu-west-3'   : {'AMI': 'ami-????????'},  # (Paris) # N/A
                'eu-west-1'     : {'AMI': 'ami-62b5fb1b'},  # (Ireland)
                'eu-west-2'     : {'AMI': 'ami-876a8de0'},  # (London)
                'eu-central-1'  : {'AMI': 'ami-55bfd73a'},  # (Frankfurt)
                'ap-northeast-1': {'AMI': 'ami-57662d31'},  # (Tokyo)
                'ap-northeast-2': {'AMI': 'ami-49bd1127'},  # (Seoul)
                'ap-southeast-1': {'AMI': 'ami-27baeb5b'},  # (Singapore)
                'ap-southeast-2': {'AMI': 'ami-00d61562'},  # (Sydney)
                'ca-central-1'  : {'AMI': 'ami-64038400'},  # (Canada)
                'ap-south-1'    : {'AMI': 'ami-e780d988'},  # (Mumbai)
                'sa-east-1'     : {'AMI': 'ami-9c0154f0'},  # (Sao Paulo)
            }
        )

    def add_resource_and_output(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        networkinterfaces = []
        for di, netintid in variables['NetworkInterfaces'].iteritems():
            networkinterfaces.append(
                ec2.NetworkInterfaceProperty(
                    DeviceIndex=di,
                    NetworkInterfaceId=netintid
                )
            )

        ec2instance = template.add_resource(
            ec2.Instance(
                'PaEc2Instance',
                DisableApiTermination='true',
                # s4f # IamInstanceProfile=variables['InstanceProfile'].ref,
                ImageId=FindInMap(
                    'PaAmiRegionMap', Ref('AWS::Region'), 'AMI'
                ),
                InstanceType=variables['InstanceType'].ref,
                KeyName=variables['KeyName'].ref,
                Monitoring=variables['DetailedMonitoring'].ref,
                NetworkInterfaces=networkinterfaces,
                Tags=Tags(variables['Tags']),
                Tenancy=variables['PlacementTenancy'].ref,
            )
        )

        template.add_output(
            Output(
                '{}Id'.format(ec2instance.title),
                Description='ID of EC2 Instance created',
                Export=Export(
                    Sub('${AWS::StackName}-%sId' % ec2instance.title)
                ),
                Value=Ref(ec2instance)
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates a Palo Alto AWS EC2 Instance'
            ' using their AWS Market Place AMI'
            ' and attach network interfaces to it'
        )
        self.add_mappings()
        self.add_resource_and_output()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=Instance(
            'test', Context({"namespace": "test"}), None
        )
    )
