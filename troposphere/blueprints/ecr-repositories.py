#!/usr/bin/env python
"""Stacker module for creating Amazon ECR repositories."""

from re import sub
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString
from troposphere import ecr, Output, Ref
from utils import standalone_output  # pylint: disable=relative-import


class Repositories(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'RepoNames': {
            'type': list,
            'description': 'Names of ECR repositories to create',
            'default': ['testrepo1', 'testrepo2'],
        },
    }

    def add_resources_and_outputs(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        for repo in variables['RepoNames']:
            ecrrepo = template.add_resource(
                ecr.Repository(
                    '{}Repo'.format(sub('-', '', repo)),
                    RepositoryName=repo
                )
            )
            template.add_output(Output(
                '{}Name'.format(ecrrepo.title),
                Description='ECR repo name for resource: {}'.format(ecrrepo.title),
                Value=Ref(ecrrepo)
            ))

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates Amazon Elastic Container Registry (Amazon ECR)'
            ' repositories.'
        )
        self.add_resources_and_outputs()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=Repositories(
            'test', Context({"namespace": "test"}), None
        )
    )
