'use strict';

module.exports.add = async event => {
  let {n1, n2} = event;
  let output = {
    input: event,
    num1: n1,
    num2: n2,
    result: n1 + n2
  };
  console.log('output:', output);
  return output;
};
