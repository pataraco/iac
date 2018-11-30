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
        'Rules': {
            'type': list,
            'description': 'List of rules to add to a security group. List'
                           ' should be a list of dicts with the keys:'
                           ' FromPort, ToPort, IpProtocol (optional [tcp, udp'
                           ' or icmp] default: tcp), FromCidr or FromSgId',
            'default': [
                {'FromPort':80, 'ToPort':80, 'IpProtocol': 'udp',
                 'FromCidr': '0.0.0.0/0'},
                {'FromPort':443, 'ToPort':443,
                 'FromSgId': 'sg-1111'}
            ],
        },
        'GroupId': {
            'type': CFNString,
            'description': 'Security Group ID to attach ingress rule to',
        },
    }

    def add_resources(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        for rule in variables['Rules']:
            if 'IpProtocol' in rule.keys():
                ipprotocol = rule['IpProtocol']
            else:
                ipprotocol = 'tcp'
            if 'FromCidr' in rule.keys():
                template.add_resource(
                    ec2.SecurityGroupIngress(
                        'SgIngress{}To{}{}FromCidr{}'.format(
                            rule['FromPort'], rule['ToPort'],
                            ipprotocol, sub('[/.]', '', rule['FromCidr'])
                        ),
                        FromPort=rule['FromPort'],
                        ToPort=rule['ToPort'],
                        IpProtocol=ipprotocol,
                        CidrIp=rule['FromCidr'],
                        GroupId=variables['GroupId'].ref,
                    )
                )
            if 'FromSgId' in rule.keys():
                template.add_resource(
                    ec2.SecurityGroupIngress(
                        'SgIngress{}To{}{}FromSg{}'.format(
                            rule['FromPort'], rule['ToPort'],
                            ipprotocol, sub('-', '', rule['FromSgId'])
                        ),
                        FromPort=rule['FromPort'],
                        ToPort=rule['ToPort'],
                        IpProtocol=ipprotocol,
                        SourceSecurityGroupId=rule['FromSgId'],
                        GroupId=variables['GroupId'].ref,
                    )
                )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an EC2 Security Group Ingress Rule and attaches it to a'
            ' specified SG ID'
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
