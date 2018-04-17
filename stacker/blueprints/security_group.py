#!/usr/bin/env python
"""Stacker module for creating a Security Group."""

from utils import standalone_output  # pylint: disable=relative-import
from troposphere import ec2, Export, Output, Ref, Tags, Sub
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString, EC2VPCId


class SecurityGroup(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'ApplicationName': {
            'type': CFNString,
            'description': 'Name of application for tagging purposes',
        },
        'EnvironmentName': {
            'type': CFNString,
            'default': 'production',
            'description': 'Name of Environment',
        },
        'SgName': {
            'type': CFNString,
            'description': 'Name of Security Group to create',
        },
        'SgDescription': {
            'type': CFNString,
            'description': 'Description of new Security Group',
        },
        'VpcId': {
            'type': EC2VPCId,
            'description': 'VPC ID',
        },
    }

    def add_resources(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        sg = template.add_resource(
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
                "{}Id".format(sg.title),
                Description="Security Group ID",
                Value=Ref(sg),
                Export=Export(Sub('${AWS::StackName}-%sId' % sg.title))
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            "Sentient Science - Digital Clone Live - Security Group"
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=SecurityGroup('test', Context({"namespace": "test"}), None)
    )
