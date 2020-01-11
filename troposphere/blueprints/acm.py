#!/usr/bin/env python
"""Stacker module for creating ACM certificate request."""

from utils import standalone_output  # pylint: disable=relative-import
from troposphere import certificatemanager, Export, Output, Ref, Sub
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNCommaDelimitedList, CFNString


class Acm(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'DomainName': {
            'type': CFNString,
            'description': 'Name of Domain',
        },
        'AlternateDomainNames': {
            'type': CFNCommaDelimitedList,
            'description': 'Alternate domain name(s) for SSL Certificate',
        },
    }

    def add_resources(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        acm = template.add_resource(
            certificatemanager.Certificate(
                'AcmCert',
                DomainName=variables['DomainName'].ref,
                SubjectAlternativeNames=variables['AlternateDomainNames'].ref
            )
        )

        template.add_output(Output(
            "{}Arn".format(acm.title),
            Description="ARN of the ACM SSL certificate",
            Value=Ref(acm),
            Export=Export(Sub('${AWS::StackName}-%sArn' % acm.title))
        ))

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            "Creates an AWS Certificate Manager (ACM) certificate"
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=Acm('test', Context({"namespace": "test"}), None)
    )
