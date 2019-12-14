exports.handler = async (event) => {
    let {a, b} = JSON.parse(event.body);
    return {
        statusCode: 200,
        body: JSON.stringify({
            a: a,
            b: b,
            sum: a + b
        })
    }
}