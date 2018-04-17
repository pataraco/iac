#!/usr/bin/env python
"""Stacker module for creating a Fargate ECS Cluster, Service and Task Def."""

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


class Cluster(Blueprint):
    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an Amazon Elastic Container Service (Amazon ECS) cluster.'
        )
        self.add_resources()

class Service(Blueprint):
    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates an Amazon Elastic Container Service (Amazon ECS) service that runs and maintains the requested number of tasks and associated load balancers.'
        )
        self.add_resources()

class TaskDefinition(Blueprint):
    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Describes the container and volume definitions of an Amazon Elastic Container Service (Amazon ECS) task.'
        )
        self.add_resources()


class Ecs(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
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
        'EcsCloudWatchLogRetention': {
            'type': CFNNumber,
            'description': 'The number of days log events are kept in'
                           ' CloudWatch Logs. When log event expires, it gets'
                           ' automatically deleted. Possible values are: 1, 3,'
                           ' 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400,'
                           ' 545, 731, 1827, and 3653 (default: 30)',
            'default': 30,
        },
        'EcsTaskExecIamRoleArn': {
            'type': CFNString,
            'description': 'ARN of the ECS Task execution IAM Role',
            'allowed_pattern': '[a-zA-Z0-9-:/]*',
        },
        'EcsTaskRoleName': {
            'type': CFNString,
            'description': 'Name of ECS Task IAM Role',
            'allowed_pattern': '[a-zA-Z0-9-_+=.@]*',
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
        'Subnets': {
            'type': EC2SubnetIdList,
            'description': 'Private Subnet name(s) of the VPC',
        },
        'SgIdList': {
            'type': EC2SecurityGroupIdList,
            'description': 'List of Security Group IDs for the ECS Service',
        },
        'TargetGroupArn': {
            'type': CFNString,
            'description': 'ARN of ALB Target Group',
            'allowed_pattern': '[a-zA-Z0-9-:/]*',
        },
        'TaskCpu': {
            'type': CFNString,
            'description': 'Task CPU Size',
        },
        'TaskMem': {
            'type': CFNString,
            'description': 'Task Memory Size',
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

        ecstaskrole = template.add_resource(
            iam.Role(
                'EcsTaskRole',
                AssumeRolePolicyDocument=get_ecs_task_assumerole_policy(),
                RoleName=variables['EcsTaskRoleName'].ref
            )
        )

        loggroup = template.add_resource(
            logs.LogGroup(
                'CloudWatchLogGroup',
                LogGroupName=Join('', [
                    '/ecs/',
                    variables['ContainerName'].ref,
                    '-',
                    variables['EnvironmentName'].ref
                ]),
                RetentionInDays=variables['EcsCloudWatchLogRetention'].ref
            )
        )

        ecscontainerdef = ecs.ContainerDefinition(
            Image=Join('', [
                Ref('AWS::AccountId'),
                '.dkr.ecr.',
                Ref('AWS::Region'),
                '.amazonaws.com/',
                variables['ContainerName'].ref,
                '-',
                variables['EnvironmentName'].ref
            ]),
            LogConfiguration=ecs.LogConfiguration(
                LogDriver='awslogs',
                Options={
                    'awslogs-group': Ref(loggroup),
                    'awslogs-region': Ref('AWS::Region'),
                    'awslogs-stream-prefix': 'ecs'
                }
            ),
            Name=Join('-', [
                variables['ContainerName'].ref,
                variables['EnvironmentName'].ref
            ]),
            PortMappings=[
                ecs.PortMapping(ContainerPort=variables['ContainerPort'].ref)
            ]
        )

        ecstaskdef = template.add_resource(
            ecs.TaskDefinition(
                'EcsTaskDef',
                ContainerDefinitions=[ecscontainerdef],
                Cpu=variables['TaskCpu'].ref,
                Memory=variables['TaskMem'].ref,
                ExecutionRoleArn=variables['EcsTaskExecIamRoleArn'].ref,
                TaskRoleArn=Ref(ecstaskrole),
                Family=Join('-', [
                    variables['ContainerName'].ref,
                    variables['EnvironmentName'].ref
                ]),
                NetworkMode='awsvpc',
                RequiresCompatibilities=['FARGATE']
            )
        )

        ecscluster = template.add_resource(
            ecs.Cluster(
                'EcsCluster',
                ClusterName=Join('-', [
                    variables['ContainerName'].ref,
                    variables['EnvironmentName'].ref
                ])
            )
        )

        ecsservice = template.add_resource(
            ecs_service(
                'EcsService',
                Cluster=Join('-', [
                    variables['ContainerName'].ref,
                    variables['EnvironmentName'].ref
                ]),
                DeploymentConfiguration=ecs.DeploymentConfiguration(
                    MinimumHealthyPercent=variables['MinHealthyPercent'].ref,
                    MaximumPercent=variables['MaxPercent'].ref
                ),
                DesiredCount=variables['NumberOfTasks'].ref,
                HealthCheckGracePeriodSeconds=variables[
                    'HealthCheckGracePeriod'].ref,
                LaunchType='FARGATE',
                LoadBalancers=[ecs.LoadBalancer(
                    ContainerName=Join('-', [
                        variables['ContainerName'].ref,
                        variables['EnvironmentName'].ref
                    ]),
                    ContainerPort=variables['ContainerPort'].ref,
                    TargetGroupArn=variables['TargetGroupArn'].ref
                )],
                NetworkConfiguration=ecs.NetworkConfiguration(
                    AwsvpcConfiguration=ecs.AwsvpcConfiguration(
                        SecurityGroups=variables['SgIdList'].ref,
                        Subnets=variables['Subnets'].ref
                    )
                ),
                ServiceName=Join('-', [
                    variables['ContainerName'].ref,
                    variables['EnvironmentName'].ref
                ]),
                TaskDefinition=Ref(ecstaskdef)
            )
        )

        template.add_output(
            Output(
                "{}Arn".format(ecstaskrole.title),
                Description="ECS Task Role ARN",
                Value=GetAtt(ecstaskrole, "Arn"),
                Export=Export(
                    Sub('${AWS::StackName}-%sArn' % ecstaskrole.title)
                )
            )
        )

        template.add_output(
            Output(
                "{}Name".format(ecstaskrole.title),
                Description="ECS Task Role Name",
                Value=Ref(ecstaskrole)
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

        template.add_output(
            Output(
                "{}Arn".format(ecscluster.title),
                Description="ECS Cluster ARN",
                Value=GetAtt(ecscluster, "Arn"),
                Export=Export(
                    Sub('${AWS::StackName}-%sArn' % ecscluster.title)
                )
            )
        )

        template.add_output(
            Output(
                "{}Arn".format(ecstaskdef.title),
                Description="ARN of the Task Definition",
                Value=Ref(ecstaskdef),
                Export=Export(
                    Sub('${AWS::StackName}-%sArn' % ecstaskdef.title)
                )
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Creates ECS (Fargate) Cluster, Service & Task Definition'
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=Ecs('test', Context({"namespace": "test"}), None)
    )
