#!/usr/bin/env python
"""Stacker module for creating an Amazon ECR repository."""

from re import sub
from utils import standalone_output  # pylint: disable=relative-import
from troposphere import ecr, Output, Ref
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNString


class Repository(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'EnvironmentName': {
            'type': CFNString,
            'default': 'production',
            'description': 'Name of Environment',
        },
        'RepoNames': {
            'type': list,
            'description': 'Names of repositories to create',
            'default': ['testrepo1', 'testrepo2'],
        },
    }

    def add_resources(self):
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
                ecrrepo.title,
                Description='ECR repo ({})'.format(ecrrepo.title),
                Value=Ref(ecrrepo)
            ))

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an Amazon Elastic Container Registry (Amazon ECR)'
            ' repository.'
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=Repository('test', Context({"namespace": "test"}), None)
    )
