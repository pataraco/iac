#!/usr/bin/env python
"""Module with SNS alert topic."""

from utils import standalone_output, version  # pylint: disable=relative-import

from troposphere import Ref, Output, sns

from stacker.blueprints.base import Blueprint


class SnsTopic(Blueprint):
    """Blueprint for setting up SNS topic."""

    VARIABLES = {}

    def add_resources(self):
        """Add resources to template."""
        template = self.template

        pagerdutyalert = template.add_resource(
            sns.Topic(
                'Topic'
            )
        )

        template.add_output(
            Output(
                "%sARN" % pagerdutyalert.title,
                Description='SNS topic',
                Value=Ref(pagerdutyalert)
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Onica Platform - Core'
            ' - SNS Topic - {}'.format(version.version())
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(SnsTopic('test',
                                    Context({"namespace": "test"}),
                                    None))
