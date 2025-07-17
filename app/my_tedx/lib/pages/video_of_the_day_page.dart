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
      debugPrint('Errore durante la ricerca per la data: $e'); // Usa debugPrint
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centralizza gli elementi della colonna
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Centralizza il contenuto all'interno della Card
                  mainAxisSize: MainAxisSize.min, // La colonna occupa lo spazio minimo necessario
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
                          : const Text('Cerca Video di Oggi'),
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
                      // Utilizziamo un SizedBox o un Container con altezza fissa
                      // o avvolgiamo in Expanded se c'è spazio sufficiente nel genitore
                      // dato che ListView.builder in una Column può dare problemi di overflow se non ha limiti
                      // Per questo caso, dato che c'è un solo video, un Column è sufficiente
                      Column(
                        children: _videosByDate.map((talk) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          elevation: 1,
                          child: ListTile(
                            title: Text(talk.title, textAlign: TextAlign.center,),
                            subtitle: Text(talk.mainSpeaker, textAlign: TextAlign.center,),
                             trailing: IconButton(
                              icon: const Icon(Icons.info),
                              onPressed: () {
                                widget.showTalkDetails(context, talk);
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
}