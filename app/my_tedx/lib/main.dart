// main.dart
import 'package:flutter/material.dart';
import 'package:my_tedx/services/api_service.dart'; // Assicurati che il percorso sia corretto
import 'package:my_tedx/models/talk.dart';
import 'package:my_tedx/models/holiday.dart'; // Mantenuto per completezza
import 'dart:developer';

void main() {
  // Avvia l'app Flutter
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEDx Video App',
      theme: ThemeData(
        primarySwatch: Colors.red, // Tema TEDx!
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<Talk> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Variabili per la ricerca per data (puoi mantenerle se vuoi anche una UI per questa)
  List<Talk> _videosByDate = [];
  bool _isLoadingDate = false;
  String? _dateErrorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Metodo per la ricerca dei video per tag
  Future<void> _searchVideos() async {
    final tag = _searchController.text.trim();
    if (tag.isEmpty) {
      setState(() {
        _errorMessage = 'Per favore, inserisci un tag per la ricerca.';
        _searchResults = []; // Pulisci i risultati precedenti
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = []; // Pulisci i risultati precedenti
    });

    try {
      final results = await _apiService.searchVideosByTag(tag);
      setState(() {
        _searchResults = results;
        if (_searchResults.isEmpty) {
          _errorMessage = 'Nessun video trovato per il tag "$tag".';
        }
      });
    } catch (e) {
      log('Errore durante la ricerca per tag: $e');
      setState(() {
        _errorMessage = 'Si è verificato un errore durante la ricerca: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Metodo per la ricerca dei video per data odierna (simile alla logica precedente)
  Future<void> _searchVideosForToday() async {
    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

    setState(() {
      _isLoadingDate = true;
      _dateErrorMessage = null;
      _videosByDate = [];
    });

    try {
      final results = await _apiService.getVideosByDate(todayDateOnly);
      setState(() {
        _videosByDate = results;
        if (_videosByDate.isEmpty) {
          _dateErrorMessage = 'Nessun video trovato per la data odierna (${todayDateOnly.toIso8601String().split('T')[0]}).';
        }
      });
    } catch (e) {
      log('Errore durante la ricerca per la data odierna: $e');
      setState(() {
        _dateErrorMessage = 'Si è verificato un errore durante la ricerca per data: $e';
      });
    } finally {
      setState(() {
        _isLoadingDate = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TEDx Video Search'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Sezione di Ricerca per Tag ---
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ricerca Video per Tag',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Inserisci un tag (es. "design")',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                              _errorMessage = null;
                            });
                          },
                        ),
                      ),
                      onSubmitted: (_) => _searchVideos(), // Permette di cercare anche con Invio
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _searchVideos,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Cerca Video'),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // --- Risultati della Ricerca per Tag ---
            Expanded(
              child: _searchResults.isEmpty && !_isLoading && _errorMessage == null
                  ? const Center(
                      child: Text('Nessun risultato. Inizia a cercare un video per tag!'),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final talk = _searchResults[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2,
                          child: ListTile(
                            title: Text(talk.title),
                            subtitle: Text(talk.mainSpeaker),
                            trailing: IconButton(
                              icon: const Icon(Icons.info),
                              onPressed: () {
                                // Qui puoi navigare a una pagina di dettagli
                                // o mostrare una dialog con più info
                                _showTalkDetails(context, talk);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // --- Sezione per la ricerca per data (Opzionale, puoi attivarla) ---
            const Divider(height: 30, thickness: 2),
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Video del Giorno (API Unificata)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoadingDate ? null : _searchVideosForToday,
                      child: _isLoadingDate
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Cerca Video di Oggi'),
                    ),
                    if (_dateErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _dateErrorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (_videosByDate.isNotEmpty)
                      Column(
                        children: _videosByDate.map((talk) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          elevation: 1,
                          child: ListTile(
                            title: Text(talk.title),
                            subtitle: Text(talk.mainSpeaker),
                             trailing: IconButton(
                              icon: const Icon(Icons.info),
                              onPressed: () {
                                _showTalkDetails(context, talk);
                              },
                            ),
                          ),
                        )).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTalkDetails(BuildContext context, Talk talk) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(talk.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Speaker: ${talk.mainSpeaker}'),
                const SizedBox(height: 10),
                Text('Dettagli: ${talk.details}'),
                const SizedBox(height: 10),
                Text('URL: ${talk.url}'),
                if (talk.nextId.isNotEmpty) Text('Prossimo ID: ${talk.nextId}'),
                if (talk.watchNextTitle.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Guarda Anche:'),
                      ...talk.watchNextTitle.map((title) => Text(' - $title')).toList(),
                    ],
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Chiudi'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}