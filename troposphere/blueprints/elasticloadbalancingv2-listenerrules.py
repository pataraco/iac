#!/usr/bin/env python
"""Stacker module for creating ALB Listener Rules for a listener."""

from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNNumber, CFNString
from troposphere import elasticloadbalancingv2, Export, Output, Ref, Sub
from utils import standalone_output  # pylint: disable=relative-import


class ListenerRules(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'ListenerArn': {
            'type': CFNString,
            'description': 'ARN of the Listener to attach to',
        },
        'Rules': {
            'type': list,
            'description': 'List of rules to add to a ALB listener. List'
                           ' should be a list of dicts with the keys:'
                           ' Condition, Value, Priority, TargetGroupArn'
                           ' (Condition: host-header or path-pattern)',
            'default': [
                {'Condition':'host-header', 'Value':'www.host.com',
                 'Priority': 1, 'TargetGroupArn':'arn::targetgroup1'},
                {'Condition':'path-pattern', 'Value':'/path',
                 'Priority': 2, 'TargetGroupArn':'arn::targetgroup2'},
            ],
        },
    }

    def add_resources_and_outputs(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        for rule in variables['Rules']:
            listenerrule = template.add_resource(
                elasticloadbalancingv2.ListenerRule(
                    'ListenerRule{p}'.format(p=rule['Priority']),
                    Actions=[
                        elasticloadbalancingv2.Action(
                            TargetGroupArn=rule['TargetGroupArn'],
                            Type='forward'
                        )
                    ],
                    Conditions=[
                        elasticloadbalancingv2.Condition(
                            Field=rule['Condition'],
                            Values=[rule['Value']]
                        )
                    ],
                    ListenerArn=variables['ListenerArn'].ref,
                    Priority=rule['Priority']
                )
            )

            template.add_output(
                Output(
                    '{}Arn'.format(listenerrule.title),
                    Description='ARN of the Listener Rule {}'.format(
                        rule['Priority']
                    ),
                    Export=Export(
                        Sub('${AWS::StackName}-%sArn' % listenerrule.title)
                    ),
                    Value=Ref(listenerrule),
                )
            )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates ALB Listener Rules and attaches them'
            ' to the specified listener'
        )
        self.add_resources_and_outputs()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=ListenerRules(
            'test', Context({"namespace": "test"}), None
        )
    )
