#!/usr/bin/env python
"""Stacker module for creating S3 Bucket(s)."""

from utils import standalone_output  # pylint: disable=relative-import
from troposphere import Export, GetAtt, Output, Ref, s3, Sub
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString


class S3Bucket(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'BucketName': {
            'type': CFNString,
            'description': 'Name of S3 Bucket to create',
        },
    }

    def add_resources(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        s3bucket = template.add_resource(
            s3.Bucket(
                'S3Bucket',
                BucketName=variables['BucketName'].ref
            )
        )

        template.add_output(
            Output(
                '{}Name'.format(s3bucket.title),
                Description='{} Name'.format(s3bucket.title),
                Value=Ref(s3bucket),
                Export=Export(Sub('${AWS::StackName}-%sName' % s3bucket.title))
            )
        )

        template.add_output(
            Output(
                "{}Arn".format(s3bucket.title),
                Description='{} Arn'.format(s3bucket.title),
                Value=GetAtt(s3bucket, "Arn"),
                Export=Export(Sub('${AWS::StackName}-%sArn' % s3bucket.title))
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            "Sentient Science - Digital Clone Live - S3 Bucket"
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=S3Bucket('test', Context({"namespace": "test"}), None)
    )
