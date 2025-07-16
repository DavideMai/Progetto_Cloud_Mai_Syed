// lib/models/talk.dart
class Talk {
  final String title;
  final String details;
  final String mainSpeaker;
  final String url;
  final String nextId; // Assumendo che sia una stringa singola
  final List<String> watchNextId;
  final List<String> watchNextTitle;

  Talk.fromJson(Map<String, dynamic> jsonMap)
      : title = jsonMap['title'],
        details = jsonMap['description'],
        mainSpeaker = (jsonMap['speakers'] ?? ""),
        url = (jsonMap['url'] ?? ""),
        nextId = (jsonMap['next_id'] as String? ?? ''), // Gestisce nullabilità
        watchNextId = List<String>.from(jsonMap['watch_next_id'] ?? []), // Assicurati che sia una lista
        watchNextTitle = List<String>.from(jsonMap['watch_next_title'] ?? []); // Assicurati che sia una lista

  @override
  String toString() {
    return 'Talk(\n'
           '  title: $title,\n'
           '  details: ${details.substring(0, details.length < 50 ? details.length : 50)}... ,\n' // Tronca per output
           '  mainSpeaker: $mainSpeaker,\n'
           '  url: $url,\n'
           '  nextId: $nextId,\n'
           '  watchNextId: $watchNextId,\n'
           '  watchNextTitle: $watchNextTitle\n'
           ')';
  }
}