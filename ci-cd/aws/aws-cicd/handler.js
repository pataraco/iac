'use strict';

const moment = require('moment');

module.exports.logger = async event => {
  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: 'Serverless AWS CI/CD demo',
        version: 'v0.0.1',
        timestamp: moment().unix()
      },
      null,
      2
    ),
  };
};
