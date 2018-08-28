"""Functions that dynamically expand template parameters."""

from collections import OrderedDict
from stacker.variables import Variable


def updated_def_variables(variables, provided_var_dict, params_to_add):
    """Add CFN parameters to template based on the specified lists.

    Example params_to_add list:
        params_to_add = [
            {'var_name': 'OtherTags',
             'var_type': CFNString,
             'description': 'Extra tag value to apply to the instances'},
            {'var_name': 'OtherSGs',
             'var_type': CFNString,
             'description': 'Extra security group to apply to the instances'}
        ]
    """
    for param_to_add in params_to_add:
        if param_to_add['var_name'] in provided_var_dict:
            for key, _value in provided_var_dict[param_to_add['var_name']].value.iteritems():  # noqa pylint: disable=C0301
                variables[key] = {
                    'type': param_to_add['var_type'],
                    'description': param_to_add['description']
                }
    return variables


def update_var_dict(provided_var_dict, params_to_add):
    """Return a dictionary to add to resolve_variables()'s variable_dict."""
    additional_vars = {}
    for param_to_add in params_to_add:
        if param_to_add['var_name'] in provided_var_dict:
            for key, value in provided_var_dict[param_to_add['var_name']].value.iteritems():  # noqa pylint: disable=C0301
                if isinstance(value, (dict, OrderedDict)):
                    additional_vars[key] = Variable(key, dict(value)['Value'])
                else:
                    additional_vars[key] = Variable(key, value)
    return additional_vars
