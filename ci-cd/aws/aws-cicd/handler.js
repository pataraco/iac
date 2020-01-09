'use strict';

const moment = require('moment');

module.exports.logger = async event => {
  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: 'Serverless AWS CI/CD demo',
        version: 'v0.1.1',
        environment: process.env.ENVIRONMENT,
        timestamp: moment().unix()
      },
      null,
      2
    ),
  };
};