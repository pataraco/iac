#!/usr/bin/env python
"""Stacker module for creating a Security Group Ingress Rule."""

from re import sub
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString
from troposphere import ec2
from utils import standalone_output  # pylint: disable=relative-import


class SecurityGroupIngressRules(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'GroupId': {
            'type': CFNString,
            'description': 'Security Group ID to attach ingress rule to',
        },
        'Rules': {
            'type': dict,
            'description': 'List of rules to add to a security group. List'
                           ' should be a dict of dicts with the keys:'
                           ' FromPort, ToPort, IpProtocol (optional [tcp, udp'
                           ' or icmp] default: tcp), Description (optional),'
                           ' CidrIp or SourceSecurityGroupId',
            'default': {
                'rule1': {'FromPort': 80, 'ToPort': 80, 'IpProtocol': 'udp',
                          'CidrIp': '0.0.0.0/0', 'Description': 'test rule'},
                'rule2': {'FromPort': 443, 'ToPort': 443,
                          'SourceSecurityGroupId': 'sg-1111'}
            },
        },
    }

    def add_resources(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        for rule, settings in variables['Rules'].iteritems():
            if 'IpProtocol' not in settings.keys():
                settings['IpProtocol'] = 'tcp'
            template.add_resource(
                ec2.SecurityGroupIngress(
                    'SgIngress{}'.format(sub('[/.-]', '', rule)),
                    GroupId=variables['GroupId'].ref,
                    **settings
                )
            )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates and attaches EC2 Security Group Ingress Rules to a'
            ' specified EC2 Security Group ID'
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=SecurityGroupIngressRules(
            'test', Context({"namespace": "test"}), None
        )
    )
