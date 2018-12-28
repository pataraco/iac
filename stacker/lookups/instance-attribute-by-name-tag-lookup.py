"""Stacker custom lookup to get EC2 Instance attributes using a 'Name' tag."""

import logging
from stacker.session_cache import get_session

TYPE_NAME = 'EC2AttrByNameTag'
LOGGER = logging.getLogger(__name__)

def handler(value, provider, **kwargs):  # pylint: disable=W0613
    """ Lookup a EC2 Instance's attribute by it's 'Name' tag value.

    Need to specify the name tag value and attribute name (same as with
    the `aws ec2 describe-instances` command.

    Region is obtained from the environment file

    [in the environment file]:
      region: us-east-1

    For example:

    [in the stacker yaml (configuration) file]:

      lookups:
        EC2AttrByNameTag: lookups.instance-attribute-by-name-tag-lookup.handler

      variables:
        InstanceId: ${EC2AttrByNameTag ${instance_name_tag}::InstanceID}
        ImageId: ${EC2AttrByNameTag ${instance_name_tag}::ImageId}
    """

    name_tag_val = value.split('::')[0]
    inst_attr = value.split('::')[1]

    session = get_session(provider.region)
    ec2_client = session.client('ec2')
    describe_instances_output = ec2_client.describe_instances(
        Filters=[{'Name': 'instance-state-name', 'Values': ['running']},
                 {'Name': 'tag:Name', 'Values': [name_tag_val]}])
    reservations = describe_instances_output['Reservations']
    if reservations:
        number_found = len(reservations)
        LOGGER.debug('found %s instances', number_found)
        if number_found == 1:
            instance = reservations[0]['Instances'][0]
            if inst_attr in ['ImageId',
                             'InstanceId',
                             'InstanceType',
                             'KeyName',
                             'LaunchTime',
                             'Platform',
                             'PrivateIpAddress',
                             'PublicIpAddress',
                             'VpcId']:
                inst_attr_val = instance[inst_attr]
            else:
                return ('error: unsupported attribute lookup'
                        ' type ({})'.format(inst_attr))
        else:
            return 'error: too many matching instances'
    else:
        LOGGER.debug('did not find any matching instances')
        return 'error: no matching instances'

    LOGGER.debug('found EC2 instance attribute %s (%s)'
                 ' with name tag (%s)', inst_attr, inst_attr_val, name_tag_val)
    return inst_attr_val
