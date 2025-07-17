// lib/pages/tag_search_page.dart
import 'package:flutter/material.dart';
import 'package:my_tedx/services/api_service.dart';
import 'package:my_tedx/models/talk.dart';
import 'package:my_tedx/utils/app_colors.dart'; // Importa il file dei colori

class TagSearchPage extends StatefulWidget {
  final ApiService apiService;
  final Function(BuildContext, Talk) showTalkDetails;

  const TagSearchPage({
    super.key,
    required this.apiService,
    required this.showTalkDetails,
  });

  @override
  State<TagSearchPage> createState() => _TagSearchPageState();
}

class _TagSearchPageState extends State<TagSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Talk> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchVideos() async {
    final tag = _searchController.text.trim();
    if (tag.isEmpty) {
      setState(() {
        _errorMessage = 'Per favorere, inserisci un tag per la ricerca.';
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = [];
    });

    try {
      final results = await widget.apiService.searchVideosByTag(tag);
      setState(() {
        _searchResults = results;
        if (_searchResults.isEmpty) {
          _errorMessage = 'Nessun video trovato per il tag "$tag".';
        }
      });
    } catch (e) {
      debugPrint('Errore durante la ricerca per tag: $e');
      setState(() {
        _errorMessage = 'Si è verificato un errore durante la ricerca: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                      // AGGIUNTO QUI: Colore rosso per la label del testo
                      labelStyle: TextStyle(color: AppColors.tedxRed),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.tedxRed, width: 2.0),
                      ),
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
                    onSubmitted: (_) => _searchVideos(),
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
                              widget.showTalkDetails(context, talk);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}