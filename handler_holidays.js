const conn = require('./db');
const holiday = require('./holidays');
const mongoose = require('mongoose');



// Lambda handler
module.exports.handler = async (event, context, callback) => {
  context.callbackWaitsForEmptyEventLoop = false;
  try {
    await conn();
    let body = {};
    if (event.body) {
      body = JSON.parse(event.body);
   }

  body.doc_per_page = body.doc_per_page || 10;
  body.page = body.page || 1;

  const holidays = await holiday.find({"Date" : body.Date})
      .skip((body.doc_per_page * body.page) - body.doc_per_page)
      .limit(body.doc_per_page);

  console.log('Found talks:', holidays);

  return callback(null, {
      statusCode: 200,
      body: JSON.stringify(holidays)
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