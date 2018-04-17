#!/usr/bin/env python
"""Stacker module for creating an ECS Service."""

import pkg_resources
from distutils.version import LooseVersion
from awacs.helpers.trust import get_ecs_task_assumerole_policy
from utils import standalone_output  # pylint: disable=relative-import
from troposphere import ecs, iam, Export, GetAtt, Join, logs, Output, Ref, Sub
from troposphere.validators import positive_integer
from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import (
    CFNNumber, CFNString, EC2SecurityGroupIdList, EC2SubnetIdList
)


class Service(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'ClusterArn': {
            'type': CFNString,
            'description': 'ARN of the ECS cluster to run the ECS service on',
            'allowed_pattern': '[a-zA-Z0-9-:/]*',
        },
        'ContainerName': {
            'type': CFNString,
            'description': 'Name of Container',
            'allowed_pattern': '[a-zA-Z0-9-_]*',
        },
        'ContainerPort': {
            'type': CFNNumber,
            'description': 'The port number on the container to direct load'
                           ' balancer traffic to. Container instances must'
                           ' allow ingress traffic on this port (default: 80)',
            'default': 80,
        },
        'EnvironmentName': {
            'type': CFNString,
            'default': 'production',
            'description': 'Name of Environment',
        },
        'HealthCheckGracePeriod': {
            'type': CFNNumber,
            'description': 'Service Health Check Grace Period (seconds)',
            'max_value': '1800',
            'min_value': '30',
        },
        'LaunchType': {
            'type': CFNString,
            'description': 'The launch type on which to run the service'
                           ' (valid values: EC2 and FARGATE. default: EC2).',
            'allowed_values': ['EC2', 'FARGATE'],
            'default': 'EC2',
        },
        'MaxPercent': {
            'type': CFNNumber,
            'description': 'Maximum Percent for Running Tasks',
        },
        'MinHealthyPercent': {
            'type': CFNNumber,
            'description': 'Minimun Healthy Percent for Running Tasks',
        },
        'NumberOfTasks': {
            'type': CFNNumber,
            'default': 1,
            'description': 'Number of Tasks to run',
        },
        # SgIdList and Subnets only needed for 'awsvpc' network mode
        #'SgIdList': {
        #    'type': EC2SecurityGroupIdList,
        #    'description': 'List of Security Group IDs for the ECS Service',
        #},
        #'Subnets': {
        #    'type': EC2SubnetIdList,
        #    'description': 'Private Subnet name(s) of the VPC',
        #},
        'TargetGroupArn': {
            'type': CFNString,
            'description': 'ARN of an ALB Target Group if desired'
                           ' (default: none)',
            'allowed_pattern': '[a-zA-Z0-9-:/]*',
            'default': '',
        },
        'TaskDefinitionArn': {
            'type': CFNString,
            'description': 'ARN of of the task definiton (including the'
                           ' revision number) that you want to run on the'
                           ' cluster, such as arn:aws:ecs:us-east-1:123456789'
                           '012:task-definition/mytask:3. You cannot use'
                           ' :latest to specify a revision because it is'
                           ' ambiguous. For example, if AWS CloudFormation'
                           ' needed to roll back an update, it would not know'
                           ' which revision to roll back to. However the'
                           ' latest revision number will be used if not'
                           ' specified',
            'allowed_pattern': '[a-zA-Z0-9-:/]*',
        },
    }

    def add_resources(self):
        """Add resources to template."""
        class EcsServiceWithHealthCheckGracePeriodSeconds(ecs.Service):
            """ECS Service class with HealthCheckGracePeriodSeconds added."""

            props = ecs.Service.props
            props['HealthCheckGracePeriodSeconds'] = (positive_integer, False)

        pkg_version = pkg_resources.get_distribution('troposphere').version
        if LooseVersion(pkg_version) < LooseVersion('2.1.3'):
            ecs_service = EcsServiceWithHealthCheckGracePeriodSeconds
        else:
            ecs_service = ecs.Service

        template = self.template
        variables = self.get_variables()

        ecsservice = template.add_resource(
            ecs_service(
                'EcsService',
                ServiceName=Join('-', [
                    variables['ContainerName'].ref,
                    variables['EnvironmentName'].ref
                ]),
                Cluster=variables['ClusterArn'].ref,
                DeploymentConfiguration=ecs.DeploymentConfiguration(
                    MinimumHealthyPercent=variables['MinHealthyPercent'].ref,
                    MaximumPercent=variables['MaxPercent'].ref
                ),
                DesiredCount=variables['NumberOfTasks'].ref,
                HealthCheckGracePeriodSeconds=variables[
                    'HealthCheckGracePeriod'].ref,
                LaunchType=variables['LaunchType'].ref,
                # TODO: put an IF function or conditional here
                LoadBalancers=[ecs.LoadBalancer(
                    #ContainerName=Join('-', [
                    #    variables['ContainerName'].ref,
                    #    variables['EnvironmentName'].ref
                    #]),
                    ContainerName=variables['ContainerName'].ref,
                    ContainerPort=variables['ContainerPort'].ref,
                    TargetGroupArn=variables['TargetGroupArn'].ref
                )],
                # NetworkConfiguration needed for 'awsvpc' network mode
                # TODO: add an 'IF' CF function or Conditional
                #NetworkConfiguration=ecs.NetworkConfiguration(
                #    AwsvpcConfiguration=ecs.AwsvpcConfiguration(
                #        SecurityGroups=variables['SgIdList'].ref,
                #        Subnets=variables['Subnets'].ref
                #    )
                #),
                TaskDefinition=variables['TaskDefinitionArn'].ref,
            )
        )

        template.add_output(
            Output(
                "{}Arn".format(ecsservice.title),
                Description="ARN of the ECS Service",
                Value=Ref(ecsservice),
                Export=Export(
                    Sub('${AWS::StackName}-%sArn' % ecsservice.title)
                )
            )
        )

        template.add_output(
            Output(
                "{}Name".format(ecsservice.title),
                Description="Name of the ECS Service",
                Value=GetAtt(ecsservice, "Name"),
                Export=Export(
                    Sub('${AWS::StackName}-%sName' % ecsservice.title)
                )
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an Amazon Elastic Container Service (Amazon ECS) service'
            ' that runs and maintains the requested number of tasks and'
            ' associated load balancers.'
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=Service(
            'test', Context({"namespace": "test"}), None
        )
    )
