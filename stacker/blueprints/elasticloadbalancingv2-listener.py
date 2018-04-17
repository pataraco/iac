#!/usr/bin/env python
"""Stacker module for creating an ALB Listener."""

from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNNumber, CFNString
from troposphere import (
    elasticloadbalancingv2, Equals, Export, If, Output, Ref, Sub
)
from utils import standalone_output  # pylint: disable=relative-import


class Listener(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'AcmCertArn': {
            'type': CFNString,
            'description': 'ARN of ACM Certificate',
            'default': '',
        },
        'AlbArn': {
            'type': CFNString,
            'description': 'ARN of ALB',
        },
        'DefaultTargetGroupArn': {
            'type': CFNString,
            'description': 'ARN of the default Target Group',
        },
        'ListeningPort': {
            'type': CFNNumber,
            'description': 'ALB Listening Port',
        },
        'ListeningProtocol': {
            'type': CFNString,
            'allowed_values': ['HTTP', 'HTTPS'],
            'description': 'Listening Protocol (HTTP or HTTPS)',
        },
        'SslPolicy': {
            'type': CFNString,
            'default': 'ELBSecurityPolicy-TLS-1-1-2017-01',
            'description': 'Security policy defining ciphers and protocols',
        },
    }

    def add_resources(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        template.add_condition(
            'ProtoIsHttps',
            Equals(variables['ListeningProtocol'].ref, 'HTTPS')
        )

        listener = template.add_resource(
            elasticloadbalancingv2.Listener(
                'AlbListener',
                Certificates=If(
                    'ProtoIsHttps',
                    [elasticloadbalancingv2.Certificate(
                        CertificateArn=variables['AcmCertArn'].ref
                    )],
                    Ref('AWS::NoValue')
                ),
                DefaultActions=[
                    elasticloadbalancingv2.Action(
                        TargetGroupArn=variables['DefaultTargetGroupArn'].ref,
                        Type='forward'
                    )
                ],
                LoadBalancerArn=variables['AlbArn'].ref,
                Port=variables['ListeningPort'].ref,
                Protocol=variables['ListeningProtocol'].ref,
                SslPolicy=If(
                    'ProtoIsHttps',
                    variables['SslPolicy'].ref,
                    Ref('AWS::NoValue')
                )
            )
        )

        template.add_output(Output(
            "{}Arn".format(listener.title),
            Description="ARN of the Listener",
            Value=Ref(listener),
            Export=Export(
                Sub('${AWS::StackName}-%sArn' % listener.title)
            )
        ))

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an ALB Listener'
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=Listener(
            'test', Context({"namespace": "test"}), None
        )
    )
