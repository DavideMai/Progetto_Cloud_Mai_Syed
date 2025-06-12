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
      // It's generally better to pass a specific payload rather than the entire event
      // unless Get_Holiday_By_Date truly expects the full event structure.
      // For now, I'm keeping your original approach of passing the event.
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

        const videoSimilarities = []; // Array per salvare le relazioni

        talks.forEach(element => {
            // Assicurati che element.title esista e sia una stringa
            const videoTitle = element.title || ''; 
            // Calcola la distanza Jaro (o Jaro-Winkler)
            // Jaro restituisce 0 per nessuna similarità, 1 per similarità perfetta.
            // Se holidayName è 'Nome non trovato', la similarità sarà probabilmente bassa.
            const jaroSimilarity = distance.string.jaro(videoTitle, holidayName);
            
            // Salva l'ID del video e la similarità in un oggetto
            videoSimilarities.push({
                videoId: element._id, // Assumendo che l'ID del video sia in `_id`
                videoTitle: videoTitle, // Puoi salvare anche il titolo per debug/chiarezza
                holidayName: holidayName, // E il nome della festività
                fullVideoObject: element,
                similarityScore: jaroSimilarity
            });
        });

        videoSimilarities.sort((a, b) => b.similarityScore - a.similarityScore);

        // 2. Prendi i primi 5 video (o meno se ce ne sono meno di 5)
        const top5Videos = videoSimilarities.slice(0, 5);

        // Se vuoi solo gli ID dei 5 video:
        const top5VideoIds = top5Videos.map(video => video.videoId);

        //console.log('Top 5 Videos (full objects):', top5Videos);
        //console.log('Top 5 Video IDs:', top5VideoIds);
        
        let randomSelectedVideo = null; // Variabile per salvare l'oggetto video completo casuale

        if (top5Videos.length > 0) {
            // Genera un indice casuale tra 0 e la lunghezza dell'array - 1
            const randomIndex = Math.floor(Math.random() * top5Videos.length);
            // Seleziona l'oggetto video completo all'indice casuale
            randomSelectedVideo = top5Videos[randomIndex].fullVideoObject; // <--- Accedi all'oggetto completo
        }

        //console.log('Selected Random Video (full object):', randomSelectedVideo);

        // --- Fine delle nuove modifiche ---
        
        let finalResponse = {
          holidayName: holidayName, // Aggiungi il nome della festività qui
          selectedVideo: randomSelectedVideo // E il video selezionato
      };

      // Gestisci il caso in cui randomSelectedVideo sia null (nessun video trovato)
      if (randomSelectedVideo === null) {
          finalResponse.message = "Nessun video pertinente trovato o errore nella selezione.";
      }

      //console.log('Final Response Object:', finalResponse);
      
        return callback(null, {
            statusCode: 200,
            // Ora restituisci l'oggetto video completo selezionato casualmente
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