// index.js (o il nome del tuo file handler)

const connect_to_db = require('./db');
const videos = require('./videos');
const holidays = require('./holidays');
const winkNLP = require('wink-nlp');
const model = require('wink-eng-lite-web-model');
const nlp = winkNLP(model);
const its = nlp.its;
const as = nlp.as;
const distance = require('wink-distance');

var aws = require('aws-sdk');
var lambda = new aws.Lambda({
  region: 'us-east-1'
});

// Questo è l'handler che Lambda cerca
module.exports.get_video_by_date = async (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }
    try {
        await connect_to_db();
    // --- Invoke the Get_Holiday_By_Date Lambda function ---
    const lambdaInvokeParams = {
      FunctionName: 'Get_Holiday_By_Date',
      Payload: JSON.stringify(event)
    };

    const invokedLambdaResult = await lambda.invoke(lambdaInvokeParams).promise();

    if (invokedLambdaResult.FunctionError) {
      console.error('Error invoking Get_Holiday_By_Date Lambda:', invokedLambdaResult.FunctionError);
      return callback(null, {
        statusCode: 500,
        headers: { 'Content-Type': 'text/plain' },
        body: 'Error invoking holiday service.'
      });
    }

    var holidayData = JSON.parse(invokedLambdaResult.Payload);
    console.log('Data from Get_Holiday_By_Date Lambda:', holidayData);
    
    holidayData = holidayData ? holidayData.body : 'No title found'; // Aggiunto un fallback
    console.log('Extracted Holiday Title:', holidayData);

    try {
      holidayData = JSON.parse(holidayData);
  } catch (error) {
      console.error("Errore durante il parsing della stringa JSON:", error);
  }

  const holidayName = holidayData ? holidayData.Name : 'Nome non trovato';
        const talks = await videos.find({});

        console.log('Found talks:', talks);

        const videoSimilarities = [];

        talks.forEach(element => {
            const videoTitle = element.title || ''; 
            const jaroSimilarity = distance.string.jaro(videoTitle, holidayName);
            videoSimilarities.push({
                videoId: element._id, 
                videoTitle: videoTitle, 
                holidayName: holidayName,
                fullVideoObject: element,
                similarityScore: jaroSimilarity
            });
        });

        videoSimilarities.sort((a, b) => b.similarityScore - a.similarityScore);
        const top5Videos = videoSimilarities.slice(0, 5);
        const top5VideoIds = top5Videos.map(video => video.videoId);
        
        let randomSelectedVideo = null;

        if (top5Videos.length > 0) {
            
            const randomIndex = Math.floor(Math.random() * top5Videos.length);
            
            randomSelectedVideo = top5Videos[randomIndex].fullVideoObject; 
        }
        
        let finalResponse = {
          holidayName: holidayName,
          selectedVideo: randomSelectedVideo 
      };
      
      if (randomSelectedVideo === null) {
          finalResponse.message = "Nessun video pertinente trovato o errore nella selezione.";
      }

        return callback(null, {
            statusCode: 200,
            body: JSON.stringify(finalResponse)
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