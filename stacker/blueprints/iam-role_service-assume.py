#!/usr/bin/env python
"""Stacker module for creating an IAM role that assumes ECS tasks service."""

from awacs.aws import Action, Allow, Policy, Principal, Statement
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString
from troposphere import iam, GetAtt, Output, Ref, Sub
from utils import standalone_output  # pylint: disable=relative-import


class Role(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'RoleName': {
            'type': CFNString,
            'description': 'IAM role name to create'
                           ' (with ECS tasks assume role capability)',
            'allowed_pattern': '[a-zA-Z0-9-_+=.@]*',
        },
        'ManagedPolicyArns': {
            'type': list,
            'description': 'List of IAM managed policy ARNs'
                           ' to attach to the role',
            'default': ['testarn1', 'testarn2'],
        },
        'MakeInstanceProfile': {
            'type': bool,
            'description': 'Whether or not to make an instance profile too'
                           ' (default: False)',
            'default': False,
        },
        'PrincipalService': {
            'type': CFNString,
            'description': 'IAM service (principal) to allow to assume this'
                           ' role',
            'allowed_pattern': '[a-zA-Z0-9-.]*',
        },
    }

    def add_resources_and_outputs(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        # build the list of managed policy ARNs to attach to the role
        managed_policy_arns = []
        for mpa in variables['ManagedPolicyArns']:
            managed_policy_arns.append(mpa)

        iamrole = template.add_resource(
            iam.Role(
                'IamRole',
                AssumeRolePolicyDocument=Policy(
                    Version='2012-10-17',
                    Statement=[
                        Statement(
                            Action=[
                                Action('sts', 'AssumeRole'),
                            ],
                            Effect=Allow,
                            Principal=Principal(
                                'Service', variables['PrincipalService'].ref
                            )
                        )
                    ]
                ),
                RoleName=variables['RoleName'].ref,
                ManagedPolicyArns=managed_policy_arns
            )
        )

        template.add_output(
            Output(
                "{}Arn".format(iamrole.title),
                Description="IAM Role ARN",
                Value=GetAtt(iamrole, "Arn"),
            )
        )

        template.add_output(
            Output(
                "{}Name".format(iamrole.title),
                Description="IAM Role name",
                Value=Ref(iamrole),
            )
        )

        if variables['MakeInstanceProfile']:
            iaminstanceprofile = template.add_resource(
                iam.InstanceProfile(
                    'IamInstanceProfile',
                    Roles=[Ref(iamrole)],
                    InstanceProfileName=Ref(iamrole),
                )
            )

            template.add_output(
                Output(
                    "{}Arn".format(iaminstanceprofile.title),
                    Description="IAM Instance Profile ARN",
                    Value=GetAtt(iaminstanceprofile, "Arn"),
                )
            )

            template.add_output(
                Output(
                    "{}Name".format(iaminstanceprofile.title),
                    Description="IAM Instance Profile name",
                    Value=Ref(iaminstanceprofile),
                )
            )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an IAM Role that can assume ECS tasks service'
            ' and attaches managed policies to it'
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
