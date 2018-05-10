#!/usr/bin/env python
"""Stacker module for creating CloudWatch Alarm to recover an EC2 instance
   when it has status check failures."""

from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString, EC2InstanceId
from troposphere import cloudwatch, Join, Ref
from utils import standalone_output  # pylint: disable=relative-import


class Ec2Recover(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'AlarmName': {
            'type': CFNString,
            'description': 'ID of the EC2 Instance to monitor',
        },
        'InstanceId': {
            'type': EC2InstanceId,
            'description': 'ID of the EC2 Instance to monitor',
        },
    }

    def add_resource(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        template.add_resource(
            cloudwatch.Alarm(
                'CloudWatchAlarm',
                AlarmActions=[
                    Join(':', [
                        'arn:aws:automate',
                        Ref('AWS::Region'),
                        'ec2:recover'
                    ])
                ],
                AlarmDescription='Trigger a recovery when the instance'
                                 ' status check fails for 15 consecutive'
                                 ' minutes.',
                AlarmName=variables['AlarmName'].ref,
                ComparisonOperator='GreaterThanThreshold',
                Dimensions=[
                    cloudwatch.MetricDimension(
                        Name='InstanceId',
                        Value=variables['InstanceId'].ref
                    )
                ],
                EvaluationPeriods=15,
                MetricName='EC2_SystemStatusCheck_Failed',
                Namespace='AWS/EC2',
                Period=60,
                Statistic='Minimum',
                Threshold='0',
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an AWS CloudWatch alarm to auto-recover an EC2 Instance'
            ' when it has status check failures for 15 consecutive minutes'
        )
        self.add_resource()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=Ec2Recover(
            'test', Context({"namespace": "test"}), None
        )
    )
