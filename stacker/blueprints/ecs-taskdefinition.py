#!/usr/bin/env python
"""Stacker module for creating an ECS task definition."""

from stacker.blueprints.base import Blueprint
from stacker.blueprints.variables.types import CFNNumber, CFNString
from troposphere import ecs, Export, Join, Output, Ref, Sub
from utils import standalone_output  # pylint: disable=relative-import


class TaskDefinition(Blueprint):
    """Extends Stacker Blueprint class."""

    VARIABLES = {
        'App': {
            'type': CFNString,
            'description': 'Short Name of the Application',
        },
        #SFFU## Save for future use
        #SFFU#'ContainerCommand': {
        #SFFU#    'type': CFNString,
        #SFFU#    'description': 'The CMD value to pass to the container',
        #SFFU#},
        #SFFU#'ContainerEntryPoint': {
        #SFFU#    'type': CFNString,
        #SFFU#    'description': 'The ENTRYPOINT value to pass'
        #SFFU#                   ' to the container',
        #SFFU#},
        #SFFU#'ContainerEnvironmentVars': {
        #SFFU#    'type': dict,
        #SFFU#    'description': 'The environment variables to pass'
        #SFFU#                   ' to the container',
        #SFFU#    'default': {'var1':'val1', 'var2':'val2'},
        #SFFU#},
        #SFFU#'ContainerLinks': {
        #SFFU#    'type': list,
        #SFFU#    'description': 'The name of another container to connect to.'
        #SFFU#                   ' With links, containers can communicate with'
        #SFFU#                   ' each other without using port mappings',
        #SFFU#    'default': ['container-a', 'container-b'],
        #SFFU#},
        'ContainerName': {
            'type': CFNString,
            'description': 'Name of Container',
            'allowed_pattern': '[a-zA-Z0-9-_]*',
        },
        #SFOU## Save for optional use
        #SFOU#'ContainerPort': {
        #SFOU#    'type': CFNNumber,
        #SFOU#    'description': 'The port number on the container to direct load'
        #SFOU#                   ' balancer traffic to. Container instances must'
        #SFOU#                   ' allow ingress traffic on this port (default: 80)',
        #SFOU#    'default': 80,
        #SFOU#},
        'ContainerPorts': {
            'type': dict,
            'description': 'dict of host:container port numbers to direct'
                           ' load balancer traffic to. Container instances'
                           ' must allow ingress traffic on these ports'
                           ' (default: {0:80})',
            'default': {0:80},
        },
        #old#'ContainerPorts': {
        #old#    'type': list,
        #old#    'description': 'List of port numbers on the container to direct'
        #old#                   ' load balancer traffic to. Container instances'
        #old#                   ' must allow ingress traffic on these ports'
        #old#                   ' (default: 80)',
        #old#    'default': [80],
        #old#},
        'CwLogGroupName': {
            'type': CFNString,
            'description': 'Name of the CloudWatch logs log group for the ECS'
                           ' task to log to',
            'allowed_pattern': '[a-zA-Z0-9-/]*',
        },
        'EnvironmentName': {
            'type': CFNString,
            'default': 'production',
            'description': 'Name of Environment',
        },
        'ExecutionRoleArn': {
            'type': CFNString,
            'description': 'ARN of the ECS Task execution IAM Role',
            'allowed_pattern': '[a-zA-Z0-9-:/]*',
        },
        'LaunchType': {
            'type': CFNString,
            'description': 'The launch type the task requires'
                           ' (valid values: EC2 and FARGATE. default: EC2).',
            'allowed_values': ['EC2', 'FARGATE'],
            'default': 'EC2',
        },
        'NetworkMode': {
            'type': CFNString,
            'description': 'The Docker networking mode to use for the'
                           ' containers in the task (valid values: none,'
                           ' bridge, awsvpc and host. default: host).',
            'allowed_values': ['none', 'bridge', 'awsvpc', 'host'],
            'default': 'host',
        },
        'TaskCpu': {
            'type': CFNString,
            'description': 'Task CPU Size - The number of cpu units used by'
                           ' the task (optional with EC2 launch type)',
        },
        'TaskMem': {
            'type': CFNString,
            'description': 'Task Memory Size - The amount (in MiB) of memory'
                           ' used by the task (optional with EC2 launch type)',
        },
        'TaskRoleArn': {
            'type': CFNString,
            'description': 'ARN of the ECS Task IAM Role',
            'allowed_pattern': '[a-zA-Z0-9-:/]*',
        },
    }

    def add_resources(self):
        """Add resources to template."""
        template = self.template
        variables = self.get_variables()

        #SFFU## Save for future use
        #SFFU#environment = []
        #SFFU#for k, v in variables['ContainerEnvironmentVars'].iteritems():
        #SFFU#    environment.append(
        #SFFU#        ecs.Environment(
        #SFFU#            Name=k,
        #SFFU#            Value=v,
        #SFFU#        )
        #SFFU#    )

        #SFFU## Save for future use
        #SFFU#links = []
        #SFFU#for link in variables['ContainerLinks']:
        #SFFU#    links.append(link)

        portmappings = []
        #SFFU#for k, v in variables['ContainerEnvironmentVars'].iteritems():
        #SFFU#    environment.append(
        #SFFU#        ecs.Environment(
        #SFFU#            Name=k,
        #SFFU#            Value=v,
        #SFFU#        )
        #SFFU#    )
        for hp, cp in variables['ContainerPorts'].iteritems():
            portmappings.append(
                ecs.PortMapping(
                    HostPort=hp,
                    ContainerPort=cp,
                )
            )
        #old#for port in variables['ContainerPorts']:
        #old#    portmappings.append(
        #old#        ecs.PortMapping(
        #old#            ContainerPort=port,
        #old#            HostPort=port
        #old#        )
        #old#    )

        ecscontainerdef = ecs.ContainerDefinition(
            #SFFU## Save for future use
            #SFFU#Command=[
            #SFFU#    variables['ContainerCommand'].ref,
            #SFFU#],
            #SFFU#EntryPoint=[
            #SFFU#    variables['ContainerEntryPoint'].ref,
            #SFFU#],
            #SFFU#Environment=environment,
            #SFFU#Links=links,
            Image=Join('', [
                Ref('AWS::AccountId'),
                '.dkr.ecr.',
                Ref('AWS::Region'),
                '.amazonaws.com/',
                variables['App'].ref,
                '-',
                variables['ContainerName'].ref,
                #SFOU#'-',
                #SFOU#variables['EnvironmentName'].ref
            ]),
            LogConfiguration=ecs.LogConfiguration(
                LogDriver='awslogs',
                Options={
                    'awslogs-group': variables['CwLogGroupName'].ref,
                    'awslogs-region': Ref('AWS::Region'),
                    'awslogs-stream-prefix': 'ecs'
                }
            ),
            Name=variables['ContainerName'].ref,
            #SFOU#PortMappings=[
            #SFOU#    ecs.PortMapping(
            #SFOU#        ContainerPort=variables['ContainerPort'].ref
            #SFOU#    )
            #SFOU#]
            PortMappings=portmappings,
        )

        ecstaskdefinition = template.add_resource(
            ecs.TaskDefinition(
                'EcsTaskDefinition',
                ContainerDefinitions=[ecscontainerdef],
                Cpu=variables['TaskCpu'].ref,
                Memory=variables['TaskMem'].ref,
                ExecutionRoleArn=variables['ExecutionRoleArn'].ref,
                TaskRoleArn=variables['TaskRoleArn'].ref,
                Family=Join('-', [
                    variables['ContainerName'].ref,
                    variables['EnvironmentName'].ref
                ]),
                NetworkMode=variables['NetworkMode'].ref,
                RequiresCompatibilities=[variables['LaunchType'].ref],
                # for future reference (need to add imports and variables)
                #Volumes=[
                #    Volume(
                #        Name=variables['VolumeName'].ref,
                #        Host=Host(SourcePath=variables['VolumeSourcePath'].ref
                #    )
                #],
            )
        )

        template.add_output(
            Output(
                "{}Arn".format(ecstaskdefinition.title),
                Description="ARN of the Task Definition",
                Value=Ref(ecstaskdefinition),
                Export=Export(
                    Sub('${AWS::StackName}-%sArn' % ecstaskdefinition.title)
                )
            )
        )

    def create_template(self):
        """Create template (main function called by Stacker)."""
        self.template.add_version('2010-09-09')
        self.template.add_description(
            'Describes the container and volume definitions of an Amazon'
            ' Elastic Container Service (Amazon ECS) task. Specifies which'
            ' Docker images to use, the required resources and other'
            ' configurations related to launching the task definition through'
            ' an Amazon ECS service or task.'
        )
        self.add_resources()


# Helper section to enable easy blueprint -> template generation
# (just run `python <thisfile>` to output the json)
if __name__ == "__main__":
    from stacker.context import Context

    standalone_output.json(
        blueprint=TaskDefinition(
            'test', Context({"namespace": "test"}), None
        )
    )
