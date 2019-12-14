const AWS = require('aws-sdk');
AWS.config.update({region: 'us-west-2'});
const dynamoDb = new AWS.DynamoDB.DocumentClient();
const tableName = process.env.DB_TABLE_NAME;
exports.handler = async (event) => {
    let userid = event.pathParameters.userid;
    let {firstname, lastname, email, website} = JSON.parse(event.body);
    let item = {
        userid: userid,
        firstname: firstname,
        lastname: lastname,
        email: email,
        website: website
    }
    let data = await dynamoDb.put({
        TableName: tableName,
        Item: item
    }).promise();
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: `Data inserted/updated successfully. (userid: ${userid})`
        })
    }
}