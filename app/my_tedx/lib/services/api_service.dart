// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:developer'; // Importa il pacchetto developer
 
import '../models/talk.dart';
import '../models/holiday.dart';
 
class ApiService {
  // Sostituisci questi con i TUOI URL COMPLETI e SPECIFICI per OGNI API
  // Se un'API ha un dominio base diverso, lo metti qui direttamente.
  // Se ci sono token o chiavi API, dovrai includerli negli header o nei parametri a seconda di come la tua API li richiede.
 
  // API per la ricerca video tramite tag
  static const String _searchVideosByTagUrl = 'https://dcta2dxljk.execute-api.us-east-1.amazonaws.com/default/Get_Talks_By_tag'; // Esempio
  // API per consigliare video basandosi sui campi watchnext
  static const String _recommendVideosUrl = 'https://mhductcft3.execute-api.us-east-1.amazonaws.com/default/Get_Watch_Next'; // Esempio
  // NUOVO: API UNIFICATA per ottenere video (e festività correlate implicitamente) tramite data
  static const String _dateBasedVideoApiUrl = 'https://w5qx3dkvbc.execute-api.us-east-1.amazonaws.com/default/Get_Video_By_Date'; // Esempio
 
 
  // Metodo per cercare video tramite tag
  Future<List<Talk>> searchVideosByTag(String tag) async {
    final url = Uri.parse(_searchVideosByTagUrl); // L'URL non include più il parametro query
    try {
      final response = await http.post( // Cambiato da http.get a http.post
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8', // Imposta l'header Content-Type per JSON
        },
        body: jsonEncode(<String, String>{'tag': tag}), // Invia il tag come corpo JSON
      );
 
      if (response.statusCode == 200) {
        // La risposta potrebbe essere una stringa JSON che rappresenta una lista.
        // Ad esempio, se l'API restituisce un corpo {"body": "[{...}, {...}]"},
        // dovrai prima decodificare il JSON esterno e poi quello interno.
        // Se restituisce direttamente una lista JSON, allora va bene così.
        // Per gli esempi di AWS Lambda con API Gateway, spesso la risposta è un JSON stringificato nel campo 'body'.
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final String innerJsonString = responseBody['body']; // Supponendo che la risposta sia {"body": "..."}
 
        final List<dynamic> jsonList = json.decode(innerJsonString); // Decodifica la stringa JSON interna
        return jsonList.map((json) => Talk.fromJson(json)).toList();
      } else {
        log('Failed to load videos by tag: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load videos by tag: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log('Error searching videos: $e');
      throw Exception('Error searching videos: $e');
    }
  }
 
  // Metodo per consigliare video basandosi sui campi watchNextId
  Future<List<Talk>> getRecommendedVideos(List<String> watchNextIds) async {
    if (watchNextIds.isEmpty) {
      return [];
    }
    // Per questa API, se prende un body {"ids" : ["id1", "id2"]}, useremo POST.
    // Se è ancora un parametro query 'ids=id1,id2', allora resta GET.
    // L'URL che hai dato 'https://mhductcft3.execute-api.us-east-1.amazonaws.com/default/Get_Watch_Next'
    // suggerisce un GET con query params, ma se anche questa prende un body, fammelo sapere.
    // Per ora la lascio come GET con query params, dato che la tua specifica era solo per getByTag.
    final idsParam = watchNextIds.join(',');
    final url = Uri.parse('$_recommendVideosUrl?ids=$idsParam');
 
    try {
      final response = await http.get(url);
 
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final String innerJsonString = responseBody['body'];
        final List<dynamic> jsonList = json.decode(innerJsonString);
        return jsonList.map((json) => Talk.fromJson(json)).toList();
      } else {
        log('Failed to load recommended videos: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load recommended videos: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log('Error getting recommendations: $e');
      throw Exception('Error getting recommendations: $e');
    }
  }
 
  // Metodo per ottenere un video (o più) inerente a una data tramite l'API unificata
  Future<List<Talk>> getVideosByDate(DateTime date) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(date);
 
    final url = Uri.parse(_dateBasedVideoApiUrl); // L'URL non include più il parametro query
    try {
      final response = await http.post( // Cambiato da http.get a http.post, assumendo che anche questa prenda un body
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'date': formattedDate}), // Invia la data come corpo JSON
      );
 
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final String innerJsonString = responseBody['body'];
        final List<dynamic> jsonList = json.decode(innerJsonString);
        return jsonList.map((json) => Talk.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        log('Nessun video trovato per la data specifica (API response 404).');
        return [];
      } else {
        log('Failed to load videos by date: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load videos by date: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log('Error getting videos by date: $e');
      throw Exception('Error getting videos by date: $e');
    }
  }
}