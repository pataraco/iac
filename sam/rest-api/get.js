const AWS = require('aws-sdk');
AWS.config.update({region: 'us-west-2'});
const dynamoDb = new AWS.DynamoDB.DocumentClient();
const tableName = process.env.DB_TABLE_NAME;
exports.handler = async (event) => {
    let userid = event.pathParameters.userid;
    let data = await dynamoDb.get({
        TableName: tableName,
        Key: {
            userid: userid
        }
    }).promise();
    if (data.Item) {
        return {
            statusCode: 200,
            body: JSON.stringify(data.Item)
        }
    } else {
        // throwing an error shows up in CloudWatch logs, but
        // just produces an "Internal server error" HTTP 502 response
        // throw new Error(`User not found (userid: ${userid})`);
        return {
            statusCode: 404,
            body: JSON.stringify({
                message: `User not found (userid: ${userid})`
            })
        }
    }
}