'use strict';

module.exports.add = async event => {
  let {n1, n2} = JSON.parse(event.body);
  let output = {
    input: event.body,
    num1: n1,
    num2: n2,
    result: n1 + n2
  };
  console.log('output:', output);
  return {
    statusCode: 200,
    body: JSON.stringify(output, null, 2)
  };

  // Use this code if you don't use the http event with the LAMBDA-PROXY integration
  // return { message: 'Go Serverless v1.0! Your function executed successfully!', event };
};
