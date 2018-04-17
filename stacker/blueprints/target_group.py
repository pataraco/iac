#!/usr/bin/env python
"""Stacker module for creating an ALB Target Group."""

from utils import standalone_output  # pylint: disable=relative-import
from troposphere import (
    elasticloadbalancingv2, Export, Output, Ref, Sub, Tags
)
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import (
    CFNNumber, CFNString, EC2VPCId
)


class TargetGroup(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'AppPort': {
            'type': CFNNumber,
            'description': 'Application Listening Port',
        },
        'AppProtocol': {
            'type': CFNString,
            'allowed_values': ['HTTP', 'HTTPS', 'TCP'],
            'description': 'Application Protocol (HTTP, HTTPS or TCP)',
        },
        'ApplicationName': {
            'type': CFNString,
            'description': 'Name of Application',
        },
        'EnvironmentName': {
            'type': CFNString,
            'default': 'production',
            'description': 'Name of Environment (default: production)',
        },
        'HealthCheckIntervalSeconds': {
            'type': CFNNumber,
            'default': 30,
            'description': 'The approximate amount of time between health'
                           ' checks of an individual target (5-300 seconds)'
                           ' (default: 30)',
            'min_value': 5,
            'max_value': 300,
        },
        'HealthCheckPath': {
            'type': CFNString,
            'default': '/',
            'description': 'The destination path for health checks. This path'
                           ' must begin with a "/" character, and can be at'
                           ' most 1024 characters in length. (default: /)',
        },
        'HealthCheckPort': {
            'type': CFNString,
            'default': 'traffic-port',
            'description': 'The port the load balancer uses when performing'
                           ' health checks on targets. The default is the port'
                           ' on which each target receives traffic from the'
                           ' load balancer, but you can specify a different'
                           ' port (default: traffic-port)',
        },
        'HealthCheckProtocol': {
            'type': CFNString,
            'allowed_values': ['HTTP', 'HTTPS'],
            'default': 'HTTP',
            'description': 'The protocol the load balancer uses when'
                           ' performing health checks on targets in this'
                           ' target group (default: HTTP)',
        },
        'HealthCheckTimeoutSeconds': {
            'type': CFNNumber,
            'default': 5,
            'description': 'The amount of time, in seconds, during which no'
                           ' response means a failed health check (2-60'
                           ' seconds) (default: 5)',
            'min_value': 2,
            'max_value': 60,
        },
        'HealthyThresholdCount': {
            'type': CFNNumber,
            'default': 5,
            'description': 'The number of consecutive health checks successes'
                           ' required before considering an unhealthy target'
                           ' healthy (2-10) (default: 5)',
            'min_value': 2,
            'max_value': 10,
        },
        'UnhealthyThresholdCount': {
            'type': CFNNumber,
            'default': 2,
            'description': 'The number of consecutive health check failures'
                           ' required before considering a target unhealthy'
                           ' (2-10) (default: 2)',
            'min_value': 2,
            'max_value': 10,
        },
        'HealthCheckSuccessCodes': {
            'type': CFNString,
            'default': '200',
            'description': 'Successful health check response(s) from a target'
                           ' (Examples: 200, 202,301 or 200-299. Default:200)',
        },
        'TargetGroupName': {
            'type': CFNString,
            'description': 'Name of Target Group (max length 32)',
        },
        'TargetType': {
            'type': CFNString,
            'allowed_values': ['instance', 'ip'],
            'default': 'instance',
            'description': 'Target Type (instance or ip)',
        },
        'VpcId': {
            'type': EC2VPCId,
            'description': 'VPC ID',
        },
    }

    def add_resources(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        targetgroup = template.add_resource(
            elasticloadbalancingv2.TargetGroup(
                'TargetGroup',
                HealthCheckIntervalSeconds=variables[
                    'HealthCheckIntervalSeconds'
                ].ref,
                HealthCheckPath=variables['HealthCheckPath'].ref,
                HealthCheckPort=variables['HealthCheckPort'].ref,
                HealthCheckProtocol=variables['HealthCheckProtocol'].ref,
                HealthCheckTimeoutSeconds=variables[
                    'HealthCheckTimeoutSeconds'
                ].ref,
                HealthyThresholdCount=variables['HealthyThresholdCount'].ref,
                UnhealthyThresholdCount=variables[
                    'UnhealthyThresholdCount'
                ].ref,
                Matcher=elasticloadbalancingv2.Matcher(
                    HttpCode=variables['HealthCheckSuccessCodes'].ref
                ),
                Name=variables['TargetGroupName'].ref,
                Port=variables['AppPort'].ref,
                Protocol=variables['AppProtocol'].ref,
                Tags=Tags(
                    Application=variables['ApplicationName'].ref,
                    Environment=variables['EnvironmentName'].ref
                ),
                TargetType=variables['TargetType'].ref,
                VpcId=variables['VpcId'].ref
            )
        )

        template.add_output(Output(
            "{}Arn".format(targetgroup.title),
            Description="ARN of the Target Group",
            Value=Ref(targetgroup),
            Export=Export(
                Sub('${AWS::StackName}-%sArn' % targetgroup.title)
            )
        ))

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            "Sentient Science - Digital Clone Live - ALB Target Group"
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=TargetGroup('test', Context({"namespace": "test"}), None)
    )
