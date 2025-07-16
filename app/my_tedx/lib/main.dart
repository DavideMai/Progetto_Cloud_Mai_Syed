// main.dart
import 'package:flutter/material.dart';
import 'package:my_tedx/services/api_service.dart';
import 'package:my_tedx/models/talk.dart';

import 'dart:developer'; // <-- NUOVO: Importa il pacchetto developer

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();

  log('--- Ricerca video per tag: "AI" ---'); // <-- Modificato da print a log
  try {
    final List<Talk> aiVideos = await apiService.searchVideosByTag('AI');
    if (aiVideos.isNotEmpty) {
      log('Video trovati per "AI":'); // <-- Modificato
      for (var video in aiVideos) { // Usare for-in per iterare su liste
        log(video.toString());      // <-- Modificato
      }
      if (aiVideos[0].watchNextId.isNotEmpty) {
        log('\n--- Video raccomandati basati sul primo video trovato ---'); // <-- Modificato
        final List<Talk> recommendedVideos = await apiService.getRecommendedVideos(aiVideos[0].watchNextId);
        if (recommendedVideos.isNotEmpty) {
          log('Video raccomandati:'); // <-- Modificato
          for (var video in recommendedVideos) {
            log(video.toString()); // <-- Modificato
          }
        } else {
          log('Nessun video raccomandato trovato.'); // <-- Modificato
        }
      }
    } else {
      log('Nessun video trovato per "AI".'); // <-- Modificato
    }
  } catch (e) {
    log('Errore nella ricerca per tag: $e'); // <-- Modificato
  }

  final DateTime today = DateTime.now();
  final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

  log('\n--- Ricerca video per la data odierna (${todayDateOnly.toIso8601String().split('T')[0]}) ---'); // <-- Modificato
  try {
    final List<Talk> videosToday = await apiService.getVideosByDate(todayDateOnly);
    if (videosToday.isNotEmpty) {
      log('Video trovati per oggi:'); // <-- Modificato
      for (var video in videosToday) {
        log(video.toString()); // <-- Modificato
      }
    } else {
      log('Nessun video trovato per la data odierna.'); // <-- Modificato
    }
  } catch (e) {
    log('Errore nella ricerca per la data odierna: $e'); // <-- Modificato
  }

  log('\n--- Ricerca video per data: 2025-01-01 (Capodanno - Esempio statico) ---'); // <-- Modificato
  try {
    final DateTime targetDate = DateTime(2025, 1, 1);
    final List<Talk> videosByDate = await apiService.getVideosByDate(targetDate);
    if (videosByDate.isNotEmpty) {
      log('Video trovati per il ${targetDate.toIso8601String().split('T')[0]}:'); // <-- Modificato
      for (var video in videosByDate) {
        log(video.toString()); // <-- Modificato
      }
    } else {
      log('Nessun video trovato per il ${targetDate.toIso8601String().split('T')[0]}.'); // <-- Modificato
    }
  } catch (e) {
    log('Errore nella ricerca per data: $e'); // <-- Modificato
  }

  log('\n--- Ricerca video per data: 2025-01-04 (World Braille Day - Esempio statico) ---'); // <-- Modificato
  try {
    final DateTime targetDate = DateTime(2025, 1, 4);
    final List<Talk> videosByDate = await apiService.getVideosByDate(targetDate);
    if (videosByDate.isNotEmpty) {
      log('Video trovati per il ${targetDate.toIso8601String().split('T')[0]}:'); // <-- Modificato
      for (var video in videosByDate) {
        log(video.toString()); // <-- Modificato
      }
    } else {
      log('Nessun video trovato per il ${targetDate.toIso8601String().split('T')[0]}.'); // <-- Modificato
    }
  } catch (e) {
    log('Errore nella ricerca per data: $e'); // <-- Modificato
  }
}