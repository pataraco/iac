#!/usr/bin/env python
"""Stacker module for creating an ALB Listener Rule."""

from utils import standalone_output  # pylint: disable=relative-import
from troposphere import elasticloadbalancingv2, Export, Output, Ref, Sub
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNNumber, CFNString


class ListenerRule(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'Condition': {
            'type': CFNString,
            'allowed_values': ['host-header', 'path-pattern'],
            'description': 'Rule Condition (host-header or path-pattern)',
        },
        'Value': {
            'type': CFNString,
            'description': 'Value of the Condition (host name or path)',
        },
        'Priority': {
            'type': CFNNumber,
            'description': 'Rule Priority (must be unique)',
        },
        'ListenerArn': {
            'type': CFNString,
            'description': 'ARN of the Listener to attach to',
        },
        'TargetGroupArn': {
            'type': CFNString,
            'description': 'ARN of the Target Group to forward to',
        },
    }

    def add_resources(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        listenerrule = template.add_resource(
            elasticloadbalancingv2.ListenerRule(
                'ListenerRule',
                Actions=[
                    elasticloadbalancingv2.Action(
                        TargetGroupArn=variables['TargetGroupArn'].ref,
                        Type='forward'
                    )
                ],
                Conditions=[
                    elasticloadbalancingv2.Condition(
                        Field=variables['Condition'].ref,
                        Values=[variables['Value'].ref]
                    )
                ],
                ListenerArn=variables['ListenerArn'].ref,
                Priority=variables['Priority'].ref
            )
        )

        template.add_output(Output(
            "{}Arn".format(listenerrule.title),
            Description="ARN of the Listener Rule",
            Value=Ref(listenerrule),
            Export=Export(
                Sub('${AWS::StackName}-%sArn' % listenerrule.title)
            )
        ))

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            "Sentient Science - Digital Clone Live - ALB Listener Rule"
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=ListenerRule('test', Context({"namespace": "test"}), None)
    )
