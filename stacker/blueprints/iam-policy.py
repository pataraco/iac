#!/usr/bin/env python
"""Module to create custom IAM inline policy for a role."""

from awacs.aws import Action, Allow, Condition, Policy, Principal, Statement
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString
from troposphere import iam, Join
from utils import standalone_output  # pylint: disable=relative-import
import sys


class Role(Blueprint):
    """Extends Stacker blueprint class for policies."""

    VARIABLES = {
        'FederatedArn': {
            'type': CFNString,
            'description': 'ARN of the Federated SAML provider'
                           ' to allow access to this IAM role',
        },
        'ManagedPolicyArns': {
            'type': list,
            'description': 'List of IAM managed policy ARNs'
                           ' to attach to the role',
            'default': ['testarn1', 'testarn2'],
        },
        'RoleName': {
            'type': CFNString,
            'description': 'The name of the AWS IAM role to create',
            'default': 'baxaws-admin-role',
        },
    }

    def add_resources_and_outputs(self):
        """Create template (main function called by Stacker)."""
        template = self.template
        variables = self.get_variables()

        # Resources

        # build the list of managed policy ARNs to attach to the role
        managed_policy_arns = []
        for mpa in variables['ManagedPolicyArns']:
            managed_policy_arns.append(mpa)

        iamrole = template.add_resource(
            iam.Role(
                'IamRole',
                RoleName=variables['RoleName'].ref,
                #Description='Role for Admin team to create/update/terminate'
                #            ' App resources (future state will only allow use'
                #            ' of CloudFormation)',
                AssumeRolePolicyDocument=Policy(
                    Version='2012-10-17',
                    Statement=[
                        # Statement to use federated SAML authentication for
                        #  Trusted Relationships
                        Statement(
                            Action=[
                                Action('sts', 'AssumeRoleWithSAML'),
                            ],
                            Effect=Allow,
                            Condition=Condition(
                                StringEquals(
                                    'SAML:aud', [
                                        'https://signin.aws.amazon.com/saml'
                                    ]
                                )
                            ),
                            Principal=Principal(
                                'Federated', variables['FederatedArn'].ref
                            )
                        )
                    ]
                ),
                ManagedPolicyArns=managed_policy_arns
            )
        )

        # Outputs

        template.add_output(
            Output(
                'IamRoleName',
                Description='IAM role name',
                Value=Ref(iamrole)
            )
        )

        template.add_output(
            Output(
                "IamRoleArn".format(iamrole.title),
                Description='IAM role ARN',
                Value=GetAtt(iamrole, "Arn")
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates AWS IAM role for Admin team to create/update/terminate'
            ' App resources (future state will only allow use of'
            ' CloudFormation)'
        )
        self.add_resources_and_outputs()


class Policy(Blueprint):
    """Extends Stacker blueprint class for Inline IAM policies."""

    VARIABLES = {
        'Groups': {
            'type': CFNCommaDelimitedList,
            'description': 'List of IAM groups to attach this inline policy to',
            'default': '',
        },
        'Roles': {
            'type': CFNCommaDelimitedList,
            'description': 'List of IAM roles to attach this inline policy to',
            'default': '',
        },
        'S3BucketArn': {
            'type': CFNString,
            'description': 'S3 Bucket ARN to give access to',
        },
        'S3BucketName': {
            'type': CFNString,
            'description': 'S3 Bucket Name for App',
        },
        'PolicyName': {
            'type': CFNString,
            'description': 'Name to give the AWS IAM inline policy',
        },
        'Users': {
            'type': CFNCommaDelimitedList,
            'description': 'List of IAM users to attach this inline policy to',
            'default': '',
        },
    }

    def add_resources(self):
        """Create template (main function called by Stacker)."""
        template = self.template
        variables = self.get_variables()

        # Resources

        # build the CFN template with the specified permissions
        iam_policy_statements = []
        iam_policy_statements.append(
            Statement(
                Sid='AllowReadAccessToS3Bucket',
                Action=[
                    Action('iam', 'ListRoles'),
                    Action('iam', 'PassRole'),
                    Action('sts', 'AssumeRole'),
                    Action('s3', 'GetObject'),
                    Action('s3', 'ListBucket'),
                ],
                Effect=Allow,
                Resource=[variables['S3BucketArn'].ref]
            )
        )
        # allow Admin role to list, pass and assume Cloudformation service role
        iam_policy_statements.append(
            Statement(
                Sid='AllowListPassAssumeToRole',
                Action=[
                    Action('iam', 'ListRoles'),
                    Action('iam', 'PassRole'),
                    Action('sts', 'AssumeRole'),
                ],
                Effect=Allow,
                Resource=[variables['AssumeRoleArn'].ref]
            )
        )

        template.add_resource(
            iam.PolicyType(
                'IamPolicy',
                PolicyName=variables['PolicyName'].ref,
                PolicyDocument=Policy(
                    Version='2012-10-17',
                    Statement=iam_policy_statements,
                ),
                # pick one of the 3 below (Groups, Roles or Users)
                #Groups=variables['Groups'].ref
                Roles=variables['Roles'].ref
                #Users=variables['Users'].ref
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates and associates an IAM (inline) policy with'
            ' IAM users, roles, or groups.'
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    if len(sys.argv) > 1:
        class_name = sys.argv[1].lower()
    else:
        class_name = 'all'

    if class_name == 'role' or class_name == 'all':
        print "\n--- Role [Begin] ---"
        standalone_output.json(
            blueprint=Role(
                'test', Context({"namespace": "test"}), None
            )
        )
        print "--- Role [End] ---"

    if class_name == 'policy' or class_name == 'all':
        print "\n--- Policy [Begin] ---"
        standalone_output.json(
            blueprint=Policy(
                'test', Context({"namespace": "test"}), None
            )
        )
        print "--- Policy [End] ---"
