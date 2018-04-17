#!/usr/bin/env python
"""Module to create an IAM role and attach managed policies to it."""

from awacs.aws import Action, Allow, Condition, Policy, Principal, Statement
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString
from troposphere import iam, Join
from utils import standalone_output  # pylint: disable=relative-import


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
            'Creates an IAM role and attaches managed policies to it'
        )
        self.add_resources_and_outputs()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=Role(
            'test', Context({"namespace": "test"}), None
        )
    )
