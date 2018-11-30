#!/usr/bin/env python
"""Stacker module for creating an EC2 Security Group."""

from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString, EC2VPCId
from troposphere import ec2, Output, Ref, Tags, Sub
from utils import standalone_output  # pylint: disable=relative-import


class Instance(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
#--------------
        'Affinity': (basestring, False),
        'AvailabilityZone': (basestring, False),
        'BlockDeviceMappings': (list, False),
        'CreditSpecification': (CreditSpecification, False),
        'DisableApiTermination': (boolean, False),
        'EbsOptimized': (boolean, False),
        'ElasticGpuSpecifications': ([ElasticGpuSpecification], False),
        'HostId': (basestring, False),
        'IamInstanceProfile': (basestring, False),
        'ImageId': (basestring, True),
        'InstanceInitiatedShutdownBehavior': (basestring, False),
        'InstanceType': (basestring, False),
        'Ipv6AddressCount': (integer, False),
        'Ipv6Addresses': ([Ipv6Addresses], False),
        'KernelId': (basestring, False),
        'KeyName': (basestring, False),
        'Monitoring': (boolean, False),
        'NetworkInterfaces': ([NetworkInterfaceProperty], False),
        'PlacementGroupName': (basestring, False),
        'PrivateIpAddress': (basestring, False),
        'RamdiskId': (basestring, False),
        'SecurityGroupIds': (list, False),
        'SecurityGroups': (list, False),
        'SsmAssociations': ([SsmAssociations], False),
        'SourceDestCheck': (boolean, False),
        'SubnetId': (basestring, False),
        'Tags': ((Tags, list), False),
        'Tenancy': (basestring, False),
        'UserData': (basestring, False),
#--------------
        'ApplicationName': {
            'type': CFNString,
            'description': 'Name of Application for tagging purposes',
        },
        'EnvironmentName': {
            'type': CFNString,
            'default': 'production',
            'description': 'Name of Environment for tagging purposes',
        },
        'SgName': {
            'type': CFNString,
            'description': 'Name of Security Group to create',
        },
        'SgDescription': {
            'type': CFNString,
            'description': 'Description of the Security Group',
        },
        'VpcId': {
            'type': EC2VPCId,
            'description': 'VPC ID to create the Security Group in',
        },
    }

    def add_resource_and_output(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        ec2instance = template.add_resource(
            ec2.Instance(
                'Ec2Instance',
#--------------
                Affinity=(basestring, False),
                AvailabilityZone=(basestring, False),
                BlockDeviceMappings=(list, False),
                CreditSpecification=(CreditSpecification, False),
                DisableApiTermination=(boolean, False),
                EbsOptimized=(boolean, False),
                ElasticGpuSpecifications=([ElasticGpuSpecification], False),
                HostId=(basestring, False),
                IamInstanceProfile=(basestring, False),
                ImageId=(basestring, True),
                InstanceInitiatedShutdownBehavior=(basestring, False),
                InstanceType=(basestring, False),
                Ipv6AddressCount=(integer, False),
                Ipv6Addresses=([Ipv6Addresses], False),
                KernelId=(basestring, False),
                KeyName=(basestring, False),
                Monitoring=(boolean, False),
                NetworkInterfaces=([NetworkInterfaceProperty], False),
                PlacementGroupName=(basestring, False),
                PrivateIpAddress=(basestring, False),
                RamdiskId=(basestring, False),
                SecurityGroupIds=(list, False),
                SecurityGroups=(list, False),
                SsmAssociations=([SsmAssociations], False),
                SourceDestCheck=(boolean, False),
                SubnetId=(basestring, False),
                Tags=((Tags, list), False),
                Tenancy=(basestring, False),
                UserData=(basestring, False),
#--------------
                GroupName=variables['SgName'].ref,
                GroupDescription=variables['SgDescription'].ref,
                Tags=Tags(
                    Application=variables['ApplicationName'].ref,
                    Environment=variables['EnvironmentName'].ref,
                    Name=variables['SgName'].ref
                ),
                VpcId=variables['VpcId'].ref
            )
        )

        template.add_output(
            Output(
                '{}AZ'.format(ec2instance.title),
                Description='Availability Zone where the instance is launched',
                Value=GetAtt(ec2instance, 'AvailabilityZone'),
                Export=Export(Sub('${AWS::StackName}-%sAZ' % ec2instance.title))
            )
        )

        template.add_output(
            Output(
                '{}Id'.format(ec2instance.title),
                Description='ID of the EC2 Instance created',
                Value=Ref(ec2instance)
                Export=Export(Sub('${AWS::StackName}-%sId' % ec2instance.title))
            )
        )

        template.add_output(
            Output(
                '{}PrivateDns'.format(ec2instance.title),
                Description='The private DNS name of the instance',
                Value=GetAtt(ec2instance, 'PrivateDnsName'),
                Export=Export(Sub('${AWS::StackName}-%sPrivateDns' % ec2instance.title))
            )
        )

        template.add_output(
            Output(
                '{}PrivateIp'.format(ec2instance.title),
                Description='The private IP of the instance',
                Value=GetAtt(ec2instance, 'PrivateIp'),
                Export=Export(Sub('${AWS::StackName}-%sPrivateIp' % ec2instance.title))
            )
        )

        template.add_output(
            Output(
                '{}PublicDns'.format(ec2instance.title),
                Description='The public DNS name of the instance',
                Value=GetAtt(ec2instance, 'PublicDnsName'),
                Export=Export(Sub('${AWS::StackName}-%sPublicDns' % ec2instance.title))
            )
        )

        template.add_output(
            Output(
                '{}PublicIp'.format(ec2instance.title),
                Description='The public IP of the instance',
                Value=GetAtt(ec2instance, 'PublicIp'),
                Export=Export(Sub('${AWS::StackName}-%sPublicIp' % ec2instance.title))
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an EC2 Security Group'
        )
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
