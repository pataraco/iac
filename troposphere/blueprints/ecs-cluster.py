#!/usr/bin/env python
"""Stacker module for creating an ECS Cluster."""

from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString
from troposphere import ecs, Export, GetAtt, Output, Ref, Sub
from utils import standalone_output  # pylint: disable=relative-import


class Cluster(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'ClusterName': {
            'type': CFNString,
            'description': 'Name of the ECS Cluster to create',
            'allowed_pattern': '[a-zA-Z0-9-_]*',
        },
    }

    def add_resources(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        ecscluster = template.add_resource(
            ecs.Cluster(
                'EcsCluster',
                ClusterName=variables['ClusterName'].ref
            )
        )

        template.add_output(
            Output(
                "{}Arn".format(ecscluster.title),
                Description="ECS Cluster ARN",
                Value=GetAtt(ecscluster, "Arn"),
                Export=Export(
                    Sub('${AWS::StackName}-%sArn' % ecscluster.title)
                )
            )
        )

        template.add_output(
            Output(
                "{}Name".format(ecscluster.title),
                Description="ECS Cluster Name",
                Value=Ref(ecscluster),
                Export=Export(
                    Sub('${AWS::StackName}-%sName' % ecscluster.title)
                )
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an Amazon Elastic Container Service (Amazon ECS) cluster.'
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=Cluster(
            'test', Context({"namespace": "test"}), None
        )
    )
