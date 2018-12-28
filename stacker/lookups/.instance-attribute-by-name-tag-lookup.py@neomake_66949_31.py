"""Stacker custom lookup to get EC2 Instance attributes using a 'Name' tag."""

# TODO - not finished

import logging
from ast import literal_eval
from stacker.session_cache import get_session

TYPE_NAME = 'EC2AttrByNameTag'
LOGGER = logging.getLogger(__name__)

def handler(value, provider, **kwargs):  # pylint: disable=W0613
    """ Lookup a EC2 Instance's attribute by it's 'Name' tag value.

    Need to specify the name tag value and attribute name (same as with
    the `aws ec2 describe-instances` command.

    Region is obtained from the environment file

    For example:

    configuration file:
        InstanceId: ${EC2AttrByNameTag /aws/service/ecs/optimized-ami/amazon-linux/recommended}
        ImageId: ${EC2AttrByNameTag /aws/service/ecs/optimized-ami/amazon-linux/recommended}

    environment file:
        region: us-east-1
    """

    session = get_session(provider.region)
    ec2_client = session.client('ec2')
    describe_instances_output = ec2_client.get_parameters(Names=[value])
    parameter_value_dict = literal_eval(describe_instances_output['Parameters'][0]['Value'])
    image_id = parameter_value_dict['image_id']

    LOGGER.debug('found EC2 instance attribute %s (%s) with name tag (%s)' % (image_id, provider.region))

    return image_id
