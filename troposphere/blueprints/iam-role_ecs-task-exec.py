#!/usr/bin/env python
"""Stacker module for creating an ECS task execution IAM role."""

from awacs.helpers.trust import get_ecs_task_assumerole_policy
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString
from troposphere import iam, GetAtt, Output, Sub
from utils import standalone_output  # pylint: disable=relative-import


class Role(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'RoleName': {
            'type': CFNString,
            'description': 'IAM role name for ECS task execution',
            'allowed_pattern': '[a-zA-Z0-9-_+=.@]*',
        },
    }

    def add_resources_and_outputs(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        ecstaskexeciamrole = template.add_resource(
            iam.Role(
                'IamRoleEcsTaskExec',
                AssumeRolePolicyDocument=get_ecs_task_assumerole_policy(),
                RoleName=variables['RoleName'].ref,
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
            'Creates an IAM Role for ECS Task Execution'
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
