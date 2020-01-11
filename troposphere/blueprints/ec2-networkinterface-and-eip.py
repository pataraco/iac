#!/usr/bin/env python
"""Stacker module for creating an AWS EC2 Network Interface, and
   associating EIP(s) to the private IP(s) (optional) and then
   finally attaching it to an EC2 instance."""

from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import (
    CFNString, EC2SecurityGroupIdList
)
from troposphere import (
    ec2, Export, GetAtt, Output, Ref, Tags, Select, Sub
)
from utils import standalone_output  # pylint: disable=relative-import


class NetworkInterfaceAndEip(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'AttachEip': {
            'type': bool,
            'description': 'Indicate whether or not to attach an EIP to the'
                           ' private IP(s)',
            'default': False,
        },
        'Description': {
            'type': CFNString,
            'description': 'Description of the network interface',
        },
        'SecurityGroupIds': {
            'type': EC2SecurityGroupIdList,
            'description': 'A list of EC2 security group IDs to assign to the'
                           ' Amazon EC2 instance',
        },
        'SecondaryAddressCount': {
            'type': int,
            'description': 'The number of secondary private IP addresses that'
                           ' EC2 automatically assigns to the network'
                           ' interface (default: 0)',
            'default': 0,
        },
        'SourceDestCheck': {
            'type': CFNString,
            'description': 'Indicates whether traffic to or from the instance'
                           ' is validated or not (default: true)',
            'default': 'true',
        },
        'SubnetId': {
            'type': CFNString,
            'description': 'The ID of the subnet to launch the instance into',
        },
        'Tags': {
            'type': dict,
            'description': 'List of tags to add to the target group.'
                           ' Should be a dict of key:value pairs',
            'default': {'Name': 'TestName', 'App': 'TestApp',
                        'Env': 'TestEnv'},
        },
    }

    def add_resources_and_outputs(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        ec2networkinterface = template.add_resource(
            ec2.NetworkInterface(
                'Ec2NetworkInterface',
                Description=variables['Description'].ref,
                GroupSet=variables['SecurityGroupIds'].ref,
                SecondaryPrivateIpAddressCount=variables[
                    'SecondaryAddressCount'],
                SourceDestCheck=variables['SourceDestCheck'].ref,
                SubnetId=variables['SubnetId'].ref,
                Tags=Tags(variables['Tags']),
            )
        )

        template.add_output(
            Output(
                '{}Id'.format(ec2networkinterface.title),
                Description='ID of the EC2 Network Interface created',
                Export=Export(
                    Sub('${AWS::StackName}-%sId' % ec2networkinterface.title)
                ),
                Value=Ref(ec2networkinterface)
            )
        )

        template.add_output(
            Output(
                '{}PrimaryPrivateIp'.format(ec2networkinterface.title),
                Description='Primary Private IP of the EC2 Network Interface',
                Export=Export(
                    Sub('${AWS::StackName}-%sPrimaryPrivateIp'
                        % ec2networkinterface.title)
                ),
                Value=GetAtt(
                    ec2networkinterface, 'PrimaryPrivateIpAddress')
            )
        )

        for i in range(variables['SecondaryAddressCount']):
            template.add_output(
                Output(
                    '{}SecondaryPrivateIp{}'.format(
                        ec2networkinterface.title, i+1),
                    Description='Secondary Private IP {} of'
                                ' the EC2 Network Interface'.format(i+1),
                    Export=Export(
                        Sub('${AWS::StackName}-%sSecondaryPrivateIp%i'
                            % (ec2networkinterface.title, i+1))
                    ),
                    Value=Select(i, GetAtt(
                        ec2networkinterface, 'SecondaryPrivateIpAddresses')
                    )
                )
            )

        if variables['AttachEip']:
            # allocate and output an EIP for the primary private IP
            primaryeip = template.add_resource(
                ec2.EIP(
                    'Ec2EipPrimary',
                    Domain='vpc',
                )
            )
            template.add_output(
                Output(
                    '{}PrimaryPublicIp'.format(ec2networkinterface.title),
                    Description='Primary Public IP of'
                                ' the EC2 Network Interface',
                    Export=Export(
                        Sub('${AWS::StackName}-%sPrimaryPublicIp'
                            % ec2networkinterface.title)
                    ),
                    Value=Ref(primaryeip)
                )
            )
            # associate it to the primary private IP
            template.add_resource(
                ec2.EIPAssociation(
                    'Ec2EipPrimaryAssociation',
                    AllocationId=GetAtt(primaryeip, 'AllocationId'),
                    NetworkInterfaceId=Ref(ec2networkinterface),
                    PrivateIpAddress=GetAtt(
                        ec2networkinterface, 'PrimaryPrivateIpAddress'),
                )
            )

            # allocate and output EIP(s) for any secondary private IPs
            for i in range(variables['SecondaryAddressCount']):
                # allocate and output an EIP for a secondary private IP
                secondaryeip = template.add_resource(
                    ec2.EIP(
                        'Ec2EipSecondary{}'.format(i+1),
                        Domain='vpc',
                    )
                )
                template.add_output(
                    Output(
                        '{}SecondaryPublicIp{}'.format(
                            ec2networkinterface.title, i+1),
                        Description='Secondary Public IP {} of'
                                    ' the EC2 Network Interface'.format(i+1),
                        Export=Export(
                            Sub('${AWS::StackName}-%sSecondaryPublicIp%i'
                                % (ec2networkinterface.title, i+1))
                        ),
                        Value=Ref(secondaryeip)
                    )
                )
                # associate it to a secondary private IP
                template.add_resource(
                    ec2.EIPAssociation(
                        'Ec2EipSecondaryAssociation{}'.format(i+1),
                        AllocationId=GetAtt(secondaryeip, 'AllocationId'),
                        NetworkInterfaceId=Ref(ec2networkinterface),
                        PrivateIpAddress=Select(i, GetAtt(
                            ec2networkinterface, 'SecondaryPrivateIpAddresses')
                        )
                    )
                )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an EC2 Network Interface and optionally associates EIP(s)'
            ' to the private IP(s) and then attaches it to an EC2 Instance'
        )
        self.add_resources_and_outputs()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=NetworkInterfaceAndEip(
            'test', Context({"namespace": "test"}), None
        )
    )
