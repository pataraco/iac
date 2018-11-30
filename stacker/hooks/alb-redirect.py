"""Post build hook to add a HTTP to HTTPS redirect on an AWS ALB."""
import logging
import boto3

# from stacker.session_cache import get_session
from stacker.lookups.handlers.output import handler as output_handler

LOGGER = logging.getLogger(__name__)


def add_http_redirect(provider, context, **kwargs):
    """Add HTTP to HTTPS redirect rule to the ALB listener."""
    # session = get_session(provider.region)
    # client = session.client('elbv2')
    client = boto3.client(service_name='elbv2', region_name=provider.region)

    if kwargs.get('ListenerArn'):
        listener_arn = output_handler(
            kwargs.get('ListenerArn'),
            provider=provider,
            context=context
        )
        listener_stack = kwargs.get('ListenerArn').split(':')[0]
        LOGGER.info(
            'Attempting to create a redirect rule for %s.', listener_stack)
    else:
        LOGGER.warn('Missing required arguement: ListenerArn')
        return False

    if kwargs.get('ConditionType'):
        condition_type = kwargs.get('ConditionType')
    else:
        LOGGER.warn('Missing required arguement: ConditionType')
        return False

    if kwargs.get('ConditionValue'):
        condition_valu = kwargs.get('ConditionValue')
    else:
        LOGGER.warn('Missing required arguement: ConditionValue')
        return False

    if kwargs.get('Host'):
        host = kwargs.get('Host')
    else:
        host = '#{host}'

    if kwargs.get('Path'):
        path = kwargs.get('Path')
    else:
        path = '/#{path}'

    if kwargs.get('Port'):
        port = str(kwargs.get('Port'))
    else:
        port = '#{port}'

    if kwargs.get('Protocol'):
        proto = kwargs.get('Protocol')
    else:
        proto = '#{protocol}'

    if kwargs.get('Query'):
        query = kwargs.get('Query')
    else:
        query = '#{query}'

    if kwargs.get('StatusCode'):
        statuscode = kwargs.get('StatusCode')
    else:
        LOGGER.warn('Missing required argument: StatusCode')
        return False

    try:
        output = client.create_rule(
            ListenerArn=listener_arn,
            Priority=1,
            Conditions=[{
                'Field': condition_type,
                'Values': [condition_valu]
            }],
            Actions=[{
                'Type': 'redirect',
                'RedirectConfig': {
                    'Host': host,
                    'Path': path,
                    'Port': port,
                    'Protocol': proto,
                    'Query': query,
                    'StatusCode': statuscode
                }
            }]
        )
        LOGGER.debug('%s', output)
        LOGGER.info('Load balancer redirect rule creation succeeded.')
    except Exception as e:
        LOGGER.info('%s', e)
        LOGGER.warn('Load balancer redirect rule creation failed.')
        return False

    return True
