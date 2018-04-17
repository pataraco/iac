#!/usr/bin/env python
"""Stacker module for creating an ECS task execution IAM role."""

from awacs.helpers.trust import get_ecs_task_assumerole_policy
from utils import standalone_output  # pylint: disable=relative-import
from troposphere import iam, GetAtt, Output, Sub
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString


class EcsTaskExecRole(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'IamRoleName': {
            'type': CFNString,
            'description': 'IAM role name',
            'allowed_pattern': '[a-zA-Z0-9-_+=.@]*',
        },
    }

    def add_resources(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        ecstaskexeciamrole = template.add_resource(
            iam.Role(
                'EcsTaskExecIamRole',
                AssumeRolePolicyDocument=get_ecs_task_assumerole_policy(),
                RoleName=variables['IamRoleName'].ref,
                ManagedPolicyArns=[
                    'arn:aws:iam::aws:'
                    'policy/service-role/AmazonECSTaskExecutionRolePolicy'
                ]
            )
        )

        template.add_output(
            Output(
                "{}Arn".format(ecstaskexeciamrole.title),
                Description="ECS Task Execution IAM Role ARN",
                Value=GetAtt(ecstaskexeciamrole, "Arn"),
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            "ECS Task Execution IAM Role"
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=EcsTaskExecRole('test', Context({"namespace": "test"}), None)
    )
