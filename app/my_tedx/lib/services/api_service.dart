// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:developer'; // Importa il pacchetto developer

import '../models/talk.dart';
// Mantieniamo il modello Holiday sebbene non ci sia una chiamata API diretta

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
    final url = Uri.parse('$_searchVideosByTagUrl?tag=$tag'); // Aggiungi parametri query se necessario
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Talk.fromJson(json)).toList();
      } else {
        log('Failed to load videos by tag: ${response.statusCode} ${response.body}'); // Modificato da print a log
        throw Exception('Failed to load videos by tag: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log('Error searching videos: $e'); // Modificato da print a log
      throw Exception('Error searching videos: $e');
    }
  }

  // Metodo per consigliare video basandosi sui campi watchNextId
  Future<List<Talk>> getRecommendedVideos(List<String> watchNextIds) async {
    if (watchNextIds.isEmpty) {
      return [];
    }
    final idsParam = watchNextIds.join(',');
    final url = Uri.parse('$_recommendVideosUrl?ids=$idsParam'); // Aggiungi parametri query se necessario

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Talk.fromJson(json)).toList();
      } else {
        log('Failed to load recommended videos: ${response.statusCode} ${response.body}'); // Modificato da print a log
        throw Exception('Failed to load recommended videos: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log('Error getting recommendations: $e'); // Modificato da print a log
      throw Exception('Error getting recommendations: $e');
    }
  }

  // Metodo per ottenere un video (o più) inerente a una data tramite l'API unificata
  Future<List<Talk>> getVideosByDate(DateTime date) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(date);

    final url = Uri.parse('$_dateBasedVideoApiUrl?date=$formattedDate'); // Aggiungi parametri query se necessario

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        // Assumiamo che la risposta di questa API sia una lista di Talk (video)
        return jsonList.map((json) => Talk.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        log('Nessun video trovato per la data specifica (API response 404).'); // Modificato da print a log
        return [];
      } else {
        log('Failed to load videos by date: ${response.statusCode} ${response.body}'); // Modificato da print a log
        throw Exception('Failed to load videos by date: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log('Error getting videos by date: $e'); // Modificato da print a log
      throw Exception('Error getting videos by date: $e');
    }
  }

  // Il metodo _getHolidaysByDate non è più necessario come chiamata API separata,
  // dato che l'API "_dateBasedVideoApiUrl" si occupa di restituire il video inerente alla data,
  // implicitamente considerando anche le festività se rilevante.
  // Se avessi bisogno di ottenere *solo* la lista delle festività da un'API diversa,
  // questo metodo dovrebbe essere reintrodotto con un URL e una logica specifici.
}