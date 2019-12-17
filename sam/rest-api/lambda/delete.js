const AWS = require('aws-sdk');
AWS.config.update({region: 'us-west-2'});
const dynamoDb = new AWS.DynamoDB.DocumentClient();
const tableName = process.env.DB_TABLE_NAME;
exports.handler = async (event) => {
    let userid = event.pathParameters.userid;
    let data = await dynamoDb.delete({
        TableName: tableName,
        Key: {
            userid: userid
        }
    }).promise();
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: `User deleted successfully. (userid: ${userid})`
        })
    }
}