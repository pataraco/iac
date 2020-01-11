#!/usr/bin/env python
"""Stacker module for creating an ALB or NLB."""

from utils import standalone_output  # pylint: disable=relative-import
from troposphere import elasticloadbalancingv2, GetAtt, Output, Ref, Sub, Tags
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import (
    CFNString, EC2SecurityGroupIdList, EC2SubnetIdList
)


class LoadBalancer(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'LbName': {
            'type': CFNString,
            'allowed_pattern': '[a-zA-Z0-9-]*',
            'description': 'Name of load balancer to create',
        },
        'ApplicationName': {
            'type': CFNString,
            'description': 'Name of application for which the load balancer'
                           ' will be used for tagging purposes',
        },
        'EnvironmentName': {
            'type': CFNString,
            'default': 'production',
            'description': 'Name of Environment for tagging purposes',
        },
        'Scheme': {
            'type': CFNString,
            'allowed_values': ['internet-facing', 'internal'],
            'default': 'internet-facing',
            'description': 'Specify whether the load balancer is Internal or'
                           ' Internet-facing choices: internal or'
                           ' internet-facing (default: internet-facing)',
        },
        'SgIdList': {
            'type': EC2SecurityGroupIdList,
            'description': 'List of Security Group IDs for the load balancer',
        },
        'Subnets': {
            'type': EC2SubnetIdList,
            'description': 'List of Subnet Ids to attach to the load balancer',
        },
        'Type': {
            'type': CFNString,
            'description': 'Specifies the type of load balancer to create.'
                           ' Valid values are application and network.'
                           ' (default: application).',
            'allowed_values': ['application', 'network'],
            'default': 'application',
        },
    }

    def add_resources_and_outputs(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        v2lb = template.add_resource(
            elasticloadbalancingv2.LoadBalancer(
                'V2LoadBalancer',
                Name=variables['LbName'].ref,
                Scheme=variables['Scheme'].ref,
                SecurityGroups=variables['SgIdList'].ref,
                Subnets=variables['Subnets'].ref,
                Tags=Tags(
                    Application=variables['ApplicationName'].ref,
                    Environment=variables['EnvironmentName'].ref,
                    Name=variables['LbName'].ref
                ),
                Type=variables['Type'].ref
            )
        )

        template.add_output(Output(
            'LbDnsName',
            Description="DNS name of the load balancer",
            Value=GetAtt(v2lb, "DNSName"),
        ))

        template.add_output(Output(
            'LbName',
            Description="Name of the load balancer",
            Value=GetAtt(v2lb, "LoadBalancerName"),
        ))

        template.add_output(Output(
            "LbArn",
            Description="ARN of the load balancer",
            Value=Ref(v2lb),
        ))

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an AWS Application (ALB) or Network (NLB)'
            ' Elastic Load Balancer'
        )
        self.add_resources_and_outputs()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=LoadBalancer(
            'test', Context({"namespace": "test"}), None
        )
    )
