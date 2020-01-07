'use strict';

const moment = reuire('moment');

module.exports.logger = async event => {
  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: 'Serverless AWS CI/CD demo',
        version: 'v0.0.0',
        timestamp: moment().unix()
      },
      null,
      2
    ),
  };
};
