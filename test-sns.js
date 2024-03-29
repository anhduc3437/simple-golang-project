const https = require('https');

let FIREBASE_API_KEY = 'AAAAiW8gorA:APA91bFTVNpNKwnzobr-DgleqmphX32r7YrhCf7yQc_nzCN9k-pHN7BusgIKU5Gcr5HImk22RPn1Giw4pqoyiV_ZhC5QX5l4d_rJ79MEB6FaIkaIPq9duYyyNS4redhr8blrVOgyL__D'
let DEVICE_TOKEN = 'fOYNFV2j0E9VgoI4uQvItX:APA91bFLAEAUt9MLJFlWRuSZcAfmtuOXfpMwN2LUG2_wm54e4RT68R2y-lLGDvi67CbuWPs1Vhl0fcvYk_5gTbSjsTeUpJGGoFwCufzD3tlb2CyWHwXvY7WlV61v2EXOzEwSqLaP1ruU'

exports.handler = (event, context, callback) => {
    let notificationData = {
        title: 'test title',
        body: 'Message body: ' + event.Records[0].eventName,
    }
    processNotification(notificationData, context);
};

function processNotification(notificationData, context) {
    console.log(notificationData);
    const data = JSON.stringify({
        to: DEVICE_TOKEN,
        notification: {
            title: "notification title",
            body: "body bodyyyyyyy test by lambda function, " + notificationData.body
        }
    });
    const options = {
        host: 'fcm.googleapis.com',
        path: '/fcm/send',
        method: 'POST',
        headers: {
            'Authorization': 'key=' + FIREBASE_API_KEY,
            'Content-Type': 'application/json'
        }

    };

    const req = https.request(options, (res) => {
        console.log(`statusCode: ${res.statusCode}`)
        res.on('data', (d) => {
            process.stdout.write(d)
            console.log('d ', d);
        })

    })

    req.on('error', (error) => {
        console.error(error)
    })

    req.write(data)
    req.end();
    return context.succeed(buildSuccessResponse(data));

}

function buildSuccessResponse(data) {
    return {
        statusCode: 200,
        body: JSON.stringify(data),
        headers: {
            'Content-Type': 'application/json',
        }
    };
}