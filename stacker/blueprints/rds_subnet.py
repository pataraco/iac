#!/usr/bin/env python
"""Stacker module for creating RDS Subnet Group."""

from utils import standalone_output, version  # pylint: disable=relative-import

from troposphere import Join, Output, Ref, Tags, rds

from stacker.blueprints.variables.types import CFNString, EC2SubnetIdList

from stacker.blueprints.base import Blueprint


class RdsSubnet(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'EnvironmentName': {
            'type': CFNString,
            'allowed_pattern': '[a-z0-9]*',
            'default': 'production',
            'description': 'Name of Environment, all lowercase',
        },
        'PriSubnets': {
            'type': EC2SubnetIdList,
            'description': 'The ID of the Private Subnet of the environment.',
        },
    }

    def add_resources(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        dbsubnetgroup = template.add_resource(
            rds.DBSubnetGroup(
                'DBSubnetGroup',
                SubnetIds=variables['PriSubnets'].ref,
                DBSubnetGroupDescription='RDS SubnetGroup',
                Tags=Tags(
                    Name=Join('-', ['RDSSubnet', Ref('EnvironmentName')]),
                )
            )
        )
        template.add_output(
            Output(
                dbsubnetgroup.title,
                Description='Physical ID of the DB Subnet Group',
                Value=Ref(dbsubnetgroup)
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description("Sturdy Platform - RDS Subnet Group "
                                      "- {0}".format(version.version()))
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == '__main__':
    from stacker.context import Context

    standalone_output.json(
        blueprint=RdsSubnet('test',
                            Context({'namespace': 'test'}),
                            None)
    )
