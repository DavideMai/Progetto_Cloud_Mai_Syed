const connect_to_db = require('./db');
const related = require('./related');

module.exports.get_watch_next = async (event, context, callback) => {
    
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));

    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }

    
    try {
        await connect_to_db();
        console.log('=> get_watch_next');

        body.doc_per_page = body.doc_per_page || 10;
        body.page = body.page || 1;

        const talks = await related.find({ "_id" : body._id, "watch_next_id": {$exists: true, $ne: []}})
            .skip((body.doc_per_page * body.page) - body.doc_per_page)
            .limit(body.doc_per_page);

        console.log('Found talks:', talks);

        const watch_next_id = [].concat(...talks.map(related => related.watch_next_id));
        console.log('Related ids:', watch_next_id);

        return callback(null, {
            statusCode: 200,
            body: JSON.stringify(watch_next_id)
        });

    } catch (err) {
        console.error('Error fetching talks:', err);
        return callback(null, {
            statusCode: err.statusCode || 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch the talks.'
        });
    }
};