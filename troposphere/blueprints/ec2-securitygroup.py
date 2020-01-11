#!/usr/bin/env python
"""Stacker module for creating an EC2 Security Group."""

from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString, EC2VPCId
from troposphere import Export, ec2, GetAtt, Output, Tags, Sub
from utils import standalone_output  # pylint: disable=relative-import


class SecurityGroup(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
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

    def add_resource_and_output(self):
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
