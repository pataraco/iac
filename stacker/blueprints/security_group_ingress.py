#!/usr/bin/env python
"""Stacker module for creating a Security Group Ingress Rule."""

from utils import standalone_output  # pylint: disable=relative-import
from troposphere import ec2, Equals, Not
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNNumber, CFNString


class SecurityGroupIngress(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'FromPort': {
            'type': CFNNumber,
            'description': 'From Port to allow',
        },
        'ToPort': {
            'type': CFNNumber,
            'description': 'To Port to allow',
        },
        'IpProtocol': {
            'type': CFNString,
            'allowed_values': ['tcp', 'udp', 'icmp'],
            'default': 'tcp',
            'description': 'IP Protocol to allow: tcp (default), udp or icmp',
        },
        'FromCidr': {
            'type': CFNString,
            'default': '',
            'description': 'CIDR to allow traffic from',
        },
        'FromSgId': {
            'type': CFNString,
            'default': '',
            'description': 'Security Group ID to allow traffic from',
        },
        'GroupId': {
            'type': CFNString,
            'description': 'Security Group ID to attach ingress rule to',
        },
    }

    def add_conditions(self):
        """Add conditions to template."""
        template = self.template
        variables = self.get_variables()

        template.add_condition(
            'CidrDefined',
            Not(Equals(variables['FromCidr'].ref, ''))
        )

        template.add_condition(
            'SrcSgDefined',
            Not(Equals(variables['FromSgId'].ref, ''))
        )

    def add_resources(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        template.add_resource(
            ec2.SecurityGroupIngress(
                'SecurityGroupIngressFromCidr',
                FromPort=variables['FromPort'].ref,
                ToPort=variables['ToPort'].ref,
                IpProtocol=variables['IpProtocol'].ref,
                CidrIp=variables['FromCidr'].ref,
                GroupId=variables['GroupId'].ref,
                Condition='CidrDefined'
            )
        )

        template.add_resource(
            ec2.SecurityGroupIngress(
                'SecurityGroupIngressFromSg',
                FromPort=variables['FromPort'].ref,
                ToPort=variables['ToPort'].ref,
                IpProtocol=variables['IpProtocol'].ref,
                SourceSecurityGroupId=variables['FromSgId'].ref,
                GroupId=variables['GroupId'].ref,
                Condition='SrcSgDefined'
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            "Sentient Science - Digital Clone Live - "
            "Security Group Ingress Rule"
        )
        self.add_conditions()
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=SecurityGroupIngress(
            'test', Context({"namespace": "test"}), None
        )
    )
