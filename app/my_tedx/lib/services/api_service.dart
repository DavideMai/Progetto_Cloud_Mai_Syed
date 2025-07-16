// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:developer'; // Importa il pacchetto developer

import '../models/talk.dart';
// import '../models/holiday.dart'; // Holiday model non è più direttamente usato in ApiService per il parsing, ma è stato mantenuto nel main

class ApiService {
  // Sostituisci questi con i TUOI URL COMPLETI e SPECIFICI per OGNI API
  // Se un'API ha un dominio base diverso, lo metti qui direttamente.
  // Se ci sono token o chiavi API, dovrai includerli negli header o nei parametri a seconda di come la tua API li richiede.

  // API per la ricerca video tramite tag
  static const String _searchVideosByTagUrl = 'https://dcta2dxljk.execute-api.us-east-1.amazonaws.com/default/Get_Talks_By_tag';
  // API per consigliare video basandosi sui campi watchnext
  static const String _recommendVideosUrl = 'https://mhductcft3.execute-api.us-east-1.amazonaws.com/default/Get_Watch_Next';
  // API UNIFICATA per ottenere video (e festività correlate implicitamente) tramite data
  static const String _dateBasedVideoApiUrl = 'https://w5qx3dkvbc.execute-api.us-east-1.amazonaws.com/default/Get_Video_By_Date';


  // Metodo per cercare video tramite tag (Parsa direttamente la lista)
  Future<List<Talk>> searchVideosByTag(String tag) async {
    final url = Uri.parse(_searchVideosByTagUrl);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'tag': tag}), // Invia il tag come corpo JSON
      );

      log('API SearchByTag Response Status Code: ${response.statusCode}');
      // REVERTO ALLA DECODIFICA DEFAULT (solitamente UTF-8)
      log('API SearchByTag Response Body: ${response.body}');


      if (response.statusCode == 200) {
        // REVERTO ALLA DECODIFICA DEFAULT (solitamente UTF-8)
        final List<dynamic> jsonList = json.decode(response.body);
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

  // Metodo per consigliare video basandosi sui campi watchNextId (Parsa direttamente la lista)
  Future<List<Talk>> getRecommendedVideos(List<String> watchNextIds) async {
    if (watchNextIds.isEmpty) {
      return [];
    }
    final url = Uri.parse(_recommendVideosUrl);

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, List<String>>{'ids': watchNextIds}), // Invia gli IDs come corpo JSON
      );

      log('API RecommendedVideos Response Status Code: ${response.statusCode}');
      // REVERTO ALLA DECODIFICA DEFAULT (solitamente UTF-8)
      log('API RecommendedVideos Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // REVERTO ALLA DECODIFICA DEFAULT (solitamente UTF-8)
        final List<dynamic> jsonList = json.decode(response.body);
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
  // Adatta il parsing al formato {"holidayName": "...", "selectedVideo": {...}}
  // Restituisce una mappa contenente la lista di video e il nome della festività
  Future<Map<String, dynamic>> getVideosAndHolidayByDate(DateTime date) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(date);

    final url = Uri.parse(_dateBasedVideoApiUrl);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'date': formattedDate}), // Invia la data come corpo JSON
      );

      log('API VideosByDate Response Status Code: ${response.statusCode}');
      // REVERTO ALLA DECODIFICA DEFAULT (solitamente UTF-8)
      log('API VideosByDate Response Body: ${response.body}');


      if (response.statusCode == 200) {
        // REVERTO ALLA DECODIFICA DEFAULT (solitamente UTF-8)
        final Map<String, dynamic> responseData = json.decode(response.body);

        final String? holidayName = responseData['holidayName'] as String?;
        final Map<String, dynamic>? selectedVideoJson = responseData['selectedVideo'] as Map<String, dynamic>?;

        List<Talk> videos = [];
        if (selectedVideoJson != null) {
          // Crea un oggetto Talk dal JSON del video e lo aggiunge alla lista
          videos = [Talk.fromJson(selectedVideoJson)];
        }
        
        // Restituisce una mappa con la lista di video e il nome della festività
        return {
          'videos': videos,
          'holidayName': holidayName,
        };

      } else if (response.statusCode == 404) {
        log('Nessun video trovato per la data specifica (API response 404).');
        return {
          'videos': [],
          'holidayName': null, // Nessuna festività se non trova nulla
        };
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