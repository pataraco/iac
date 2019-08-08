"""Stacker custom lookup for finding AWS recommended ECS EC2 AMI"""

import logging
from ast import literal_eval
from stacker.session_cache import get_session

TYPE_NAME = 'ecsinstanceami'
LOGGER = logging.getLogger(__name__)


def handler(value, provider, **kwargs):  # pylint: disable=W0613
    """ Find the AWS recommended AMI for ECS instances
        stored in AWS managed SSM

    Need to specify the SSM key value to the lookup.
    (/aws/service/ecs/optimized-ami/amazon-linux/recommended)

    Region is obtained from the environment file

    For example:

    configuration file:
        ImageId: ${ecsinstanceami /aws/service/ecs/optimized-ami/amazon-linux/recommended}

    environment file:
        region: us-east-1
    """

    session = get_session(provider.region)
    ssm_client = session.client('ssm')
    get_parameters_output = ssm_client.get_parameters(Names=[value])
    parameter_value_dict = literal_eval(get_parameters_output['Parameters'][0]['Value'])
    image_id = parameter_value_dict['image_id']

    LOGGER.debug('found ECS image ID: %s for region: %s', image_id, provider.region)

    return image_id
