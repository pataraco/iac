#!/usr/bin/env python
"""Stacker module for creating an EC2 Security Group and its ingress rules."""

from re import sub
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString, EC2VPCId
from troposphere import ec2, Export, GetAtt, Output, Sub, Tags
from utils import standalone_output  # pylint: disable=relative-import


class SecurityGroupAndRules(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'Rules': {
            'type': dict,
            'description': 'List of rules to add to a security group. List'
                           ' should be a dict of dicts with the keys:'
                           ' FromPort, ToPort, IpProtocol (optional [tcp, udp'
                           ' or icmp] default: tcp),'
                           ' CidrIp or SourceSecurityGroupId',
            'default': {
                'rule1': {'FromPort': 80, 'ToPort': 80, 'IpProtocol': 'udp',
                          'CidrIp': '0.0.0.0/0'},
                'rule2': {'FromPort': 443, 'ToPort': 443,
                          'SourceSecurityGroupId': 'sg-1111'}
            },
        },
        'SgName': {
            'type': CFNString,
            'description': 'Name of Security Group to create',
        },
        'SgDescription': {
            'type': CFNString,
            'description': 'Description of the Security Group',
        },
        'Tags': {
            'type': dict,
            'description': 'List of tags to add to the security group.'
                           ' Should be a dict of key:value pairs',
            'default': {'Name': 'TestName', 'App': 'TestApp',
                        'Env': 'TestEnv'},
        },
        'VpcId': {
            'type': EC2VPCId,
            'description': 'VPC ID to create the Security Group in',
        },
    }

    def add_resources_and_output(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        ec2securitygroup = template.add_resource(
            ec2.SecurityGroup(
                'Sg',
                GroupName=variables['SgName'].ref,
                GroupDescription=variables['SgDescription'].ref,
                Tags=Tags(variables['Tags']),
                VpcId=variables['VpcId'].ref
            )
        )

        for rule, settings in variables['Rules'].iteritems():
            if 'IpProtocol' not in settings.keys():
                settings['IpProtocol'] = 'tcp'
            template.add_resource(
                ec2.SecurityGroupIngress(
                    'SgIngress{}'.format(sub('[/.-]', '', rule)),
                    GroupId=GetAtt(ec2securitygroup, 'GroupId'),
                    **settings
                )
            )

        template.add_output(
            Output(
                '{}Id'.format(ec2securitygroup.title),
                Description='ID of the Security Group created',
                Value=GetAtt(ec2securitygroup, 'GroupId'),
                Export=Export(
                    Sub('${AWS::StackName}-%sId' % ec2securitygroup.title)
                )
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an EC2 Security Group and its ingress rules'
        )
        self.add_resources_and_output()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=SecurityGroupAndRules(
            'test', Context({"namespace": "test"}), None
        )
    )
