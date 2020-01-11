#!/usr/bin/env python
"""Stacker module for creating EC2 routes in a route table."""

from re import sub
from stacker.blueprints.base import Blueprint
from troposphere import ec2
from utils import standalone_output  # pylint: disable=relative-import


class Routes(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'Routes': {
            'type': dict,
            'description': 'List of routes to add to the route table.'
                           ' should be a dict of dicts with the keys:'
                           ' DestinationCidrBlock, NetworkInterfaceId,'
                           ' RouteTableId',
            'default': {
                'testrte1': {'DestinationCidrBlock': '0.0.0.0/0',
                             'NetworkInterfaceId': 'eni-12345',
                             'RouteTableId': 'rtr-12345'},
                'testrte2': {'DestinationCidrBlock': '0.0.0.0/0',
                             'NetworkInterfaceId': 'eni-67890',
                             'RouteTableId': 'rtr-67890'},
            },
        },
    }

    def add_resources(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        for route, settings in variables['Routes'].iteritems():
            template.add_resource(
                ec2.Route(
                    'Route{}'.format(sub('[/.-]', '', route)),
                    **settings
                )
            )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates EC2 routes in route tables'
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=Routes(
            'test', Context({"namespace": "test"}), None
        )
    )
