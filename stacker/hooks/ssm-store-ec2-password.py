"""Post build hook to add decrypted windows password to SSM paramet store."""
import base64
import os
import logging
import boto3
import rsa

# from stacker.session_cache import get_session
from stacker.lookups.handlers.output import handler as output_handler

LOGGER = logging.getLogger(__name__)
HOME = os.environ['HOME']
PRIVATE_KEY_FILE = '{}/.ssh/onica-ext-migration.pem'.format(HOME)


def add_win_admin_pw_to_ssm(provider, context, **kwargs):
    """Add Windows Admin passowrd to SSM parameter store."""
    ec2client = boto3.client(service_name='ec2', region_name=provider.region)
    ssmclient = boto3.client(service_name='ssm', region_name=provider.region)

    if kwargs.get('InstanceId'):
        instanceid = output_handler(
            kwargs.get('InstanceId'),
            provider=provider,
            context=context
        )
    else:
        LOGGER.warn('Missing required arguement: InstanceId')
        return False

    if kwargs.get('SsmParamKey'):
        ssmparamkey = kwargs.get('SsmParamKey')
    else:
        LOGGER.warn('Missing required arguement: SsmParamKey')
        return False

    LOGGER.info('Attempting to save admin password for {} to SSM {}'.format(instanceid, ssmparamkey))

    getpwdataoutput = ec2client.get_password_data(InstanceId=instanceid)
    encryptedpw = base64.b64decode(getpwdataoutput['PasswordData'].strip())

    if encryptedpw:
        with open(PRIVATE_KEY_FILE, 'r') as privkeyfile:
            privatekey = rsa.PrivateKey.load_pkcs1(privkeyfile.read())
        decryptedpw = rsa.decrypt(encryptedpw, privatekey)
    else:
        LOGGER.warn('admin password not available.')
        return False

    try:
        putparamresponse = ssmclient.put_parameter(
            Description='Windows Administrator password',
            Name=ssmparamkey,
            Overwrite=True,
            Type='SecureString',
            Value=decryptedpw)
        LOGGER.debug('%s', putparamresponse)
        LOGGER.info('SSM put parameter succeeded.')
    except Exception as e:
        LOGGER.info('%s', e)
        LOGGER.warn('SSM put parameter failed.')
        return False

    return True
