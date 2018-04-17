#!/usr/bin/env python
"""Module to create an AWS IAM managed policy."""

from awacs.aws import Action, Allow, Condition, Policy, Statement
from awacs.aws import StringEquals   # pylint: disable=no-name-in-module
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNCommaDelimitedList, CFNString
from troposphere import iam, Output, Ref
from utils import standalone_output  # pylint: disable=relative-import


class ManagedPolicy(Blueprint):
    """Extends Stacker blueprint class for managed IAM policies."""

    VARIABLES = {
        #'AppName': {
        #    'type': CFNString,
        #    'description': 'The name of the application you are deploying.'
        #                   ' Used to create meaningful names for IAM resources'
        #                   ' and allow related access',
        #    'default': 'ApplicationName'
        #},
        'Description': {
            'type': CFNString,
            'description': 'Description of the AWS IAM managed policy',
        },
        'ManagedPolicyName': {
            'type': CFNString,
            'description': 'Name to give the AWS IAM managed policy',
        },
    }

    def add_resources_and_outputs(self):
        """Create template (main function called by Stacker)."""
        template = self.template
        variables = self.get_variables()

        # Resources

        # build the CFN template with the following specified permissions
        iam_policy_statements = []
        # allow Support role to use all commonly used services
        iam_policy_statements.append(
            Statement(
                Sid='AllowFullAccessToCommonServiceAndLimitedEc2Access',
                Action=[
                    Action('autoscaling', 'Describe*'),
                    Action('cloudwatch', 'ListMetrics'),
                    Action('cloudwatch', 'Describe*'),
                    Action('cloudwatch', 'GetMetricStatistics*'),
                    Action('ec2', 'Describe*'),
                    Action('elasticloadbalancing', 'Describe*'),
                    Action('s3', 'Get*'),
                    Action('s3', 'List*'),
                ],
                Effect=Allow,
                #Condition=Condition(
                #    StringEquals('aws:RequestTag/Appname', [
                #        variables['AppName'].ref
                #    ])
                #),
                Resource=['*']
            )
        )

        iammanagedpolicy = template.add_resource(
            iam.ManagedPolicy(
                'IamManagedPolicy',
                ManagedPolicyName=variables['ManagedPolicyName'].ref,
                Description=variables['Description'].ref,
                PolicyDocument=Policy(
                    Version='2012-10-17',
                    Statement=iam_policy_statements
                )
            )
        )

        # Outputs

        template.add_output(
            Output(
                'IamManagedPolicyArn',
                Description='Managed policy ARN',
                Value=Ref(iammanagedpolicy)
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an AWS IAM managed policy'
        )
        self.add_resources_and_outputs()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=ManagedPolicy(
            'test', Context({"namespace": "test"}), None
        )
    )
