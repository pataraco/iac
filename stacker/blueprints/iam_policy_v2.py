DELETE ME
#!/usr/bin/env python
"""Module to create custom IAM inline policy for a role."""

from utils import standalone_output  # pylint: disable=relative-import
from troposphere import iam, Join
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString
import awacs.s3
from awacs.aws import Allow, Policy, Statement


class IamInlinePolicy(Blueprint):
    """Extends Stacker blueprint class for Inline IAM policies."""

    VARIABLES = {
        'IamRoleName': {
            'type': CFNString,
            'description': 'IAM role to attach this inline policy to',
        },
        'S3BucketArn': {
            'type': CFNString,
            'description': 'S3 Bucket ARN to give access to',
        },
        'S3BucketName': {
            'type': CFNString,
            'description': 'S3 Bucket Name for App',
        },
    }

    def add_resources(self):
        """Create template (main function called by Stacker)."""
        template = self.template
        variables = self.get_variables()

        # Resources

        # build the CFN template with the specified permissions
        iam_statements = []
        iam_statements.append(
            Statement(
                Sid='AllowReadAccessToS3Bucket',
                Action=[
                    awacs.s3.GetObject,
                    awacs.s3.ListBucket
                ],
                Effect=Allow,
                Resource=[variables['S3BucketArn'].ref]
            )
        )

        template.add_resource(
            iam.PolicyType(
                'IamInlinePolicy',
                PolicyDocument=Policy(
                    Version='2012-10-17',
                    Statement=iam_statements,
                ),
                PolicyName=Join('', [
                    'S3AccessToBucket-', variables['S3BucketName'].ref
                ]),
                Roles=[variables['IamRoleName'].ref]
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            "Sentient Science - DCL - Custom IAM Inline Policy - ECS UI"
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=IamInlinePolicy('test', Context({"namespace": "test"}), None)
    )
