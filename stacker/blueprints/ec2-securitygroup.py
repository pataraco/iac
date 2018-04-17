#!/usr/bin/env python
"""Stacker module for creating an EC2 Security Group."""

from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString, EC2VPCId
from troposphere import ec2, Output, Ref, Tags, Sub
from utils import standalone_output  # pylint: disable=relative-import


class SecurityGroup(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
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

        ec2securitygroup = template.add_resource(
            ec2.SecurityGroup(
                'Sg',
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
                "{}Id".format(ec2securitygroup.title),
                Description="ID of the Security Group created",
                Value=Ref(ec2securitygroup)
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
        blueprint=SecurityGroup(
            'test', Context({"namespace": "test"}), None
        )
    )
