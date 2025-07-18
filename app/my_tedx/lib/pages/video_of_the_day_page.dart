// lib/pages/video_of_the_day_page.dart
import 'package:flutter/material.dart';
import 'package:my_tedx/services/api_service.dart';
import 'package:my_tedx/models/talk.dart';
import 'package:intl/intl.dart';

class VideoOfTheDayPage extends StatefulWidget {
  final ApiService apiService;
  final Function(BuildContext, Talk) showTalkDetails;

  const VideoOfTheDayPage({
    super.key,
    required this.apiService,
    required this.showTalkDetails,
  });

  @override
  State<VideoOfTheDayPage> createState() => _VideoOfTheDayPageState();
}

class _VideoOfTheDayPageState extends State<VideoOfTheDayPage> {
  List<Talk> _videosByDate = [];
  bool _isLoadingDate = false;
  String? _dateErrorMessage;
  String? _currentHolidayName;
  DateTime? _currentSearchDate;

  @override
  void initState() {
    super.initState();
    _searchVideosForDate(DateTime.now());
  }

  // Metodo per la ricerca dei video per data
  Future<void> _searchVideosForDate(DateTime date) async {
    setState(() {
      _isLoadingDate = true;
      _dateErrorMessage = null;
      _videosByDate = [];
      _currentHolidayName = null;
      _currentSearchDate = date;
    });

    try {
      final responseMap = await widget.apiService.getVideosAndHolidayByDate(date);
      
      setState(() {
        _videosByDate = responseMap['videos'] as List<Talk>;
        _currentHolidayName = responseMap['holidayName'] as String?;
        
        if (_videosByDate.isEmpty) {
          _dateErrorMessage = 'Nessun video trovato per il ${DateFormat('dd-MM-yyyy').format(date)}.';
          if (_currentHolidayName != null && _currentHolidayName!.isNotEmpty) {
            _dateErrorMessage = 'Nessun video trovato per il ${DateFormat('dd-MM-yyyy').format(date)} ($_currentHolidayName).';
          }
        }
      });
    } catch (e) {
      debugPrint('Errore durante la ricerca per la data: $e');
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center( // Centralizza tutto il contenuto della pagina
        child: SingleChildScrollView( // Permette lo scorrimento se il contenuto è troppo lungo
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Centralizza gli elementi della colonna
            mainAxisSize: MainAxisSize.min, // La colonna occupa lo spazio minimo necessario
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // Centralizza il contenuto all'interno della Card
                    mainAxisSize: MainAxisSize.min, // La colonna interna occupa lo spazio minimo
                    children: [
                      const Text(
                        'Video del Giorno e Festività',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center, // Centra il testo del titolo
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isLoadingDate ? null : () => _searchVideosForDate(DateTime.now()),
                        child: _isLoadingDate
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Ricarica Video di Oggi'),
                      ),
                      
                      if (_dateErrorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _dateErrorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center, // Centra il testo di errore
                          ),
                        ),
                      const SizedBox(height: 10),

                      // Visualizzazione della data e del nome della festività
                      if (_currentSearchDate != null && _videosByDate.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center, // Centra questi testi
                            children: [
                              Text(
                                'Data: ${DateFormat('dd-MM-yyyy').format(_currentSearchDate!)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              if (_currentHolidayName != null && _currentHolidayName!.isNotEmpty)
                                Text(
                                  'Festività: $_currentHolidayName',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              const SizedBox(height: 8),
                              const Text(
                                'Video trovato:',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                      // Lista dei video trovati per data
                      if (_videosByDate.isNotEmpty)
                        Column(
                          mainAxisSize: MainAxisSize.min, // Assicura che questa colonna occupi lo spazio minimo
                          children: _videosByDate.map((talk) => 
                            ConstrainedBox( // LIMITA LA LARGHEZZA DELLA CARD DEL VIDEO E PERMETTE LA CENTRATURA
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.8, // La card occupa l'80% della larghezza dello schermo
                              ),
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 4.0),
                                elevation: 1,
                                // SOSTITUITO ListTile CON UN LAYOUT PERSONALIZZATO PER UNA CENTRATURA PRECISA
                                child: InkWell( // Rende la card cliccabile come ListTile
                                  onTap: () {
                                    widget.showTalkDetails(context, talk);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        Expanded( // La colonna del testo prende tutto lo spazio rimanente
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center, // CENTRA IL TESTO NELLA COLONNA
                                            children: [
                                              Text(
                                                talk.title,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context).textTheme.titleMedium, // Applica uno stile appropriato
                                              ),
                                              if (talk.mainSpeaker.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  talk.mainSpeaker,
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(context).textTheme.bodySmall, // Applica uno stile appropriato
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        IconButton( // L'icona rimane sulla destra
                                          icon: const Icon(Icons.info),
                                          onPressed: () {
                                            widget.showTalkDetails(context, talk);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}