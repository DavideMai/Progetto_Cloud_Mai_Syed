// lib/utils/dialog_utils.dart
import 'package:flutter/material.dart';
import 'package:my_tedx/models/talk.dart'; // Assicurati il percorso corretto
import 'package:my_tedx/utils/app_colors.dart'; // Importa il file dei colori

class DialogUtils {
  static void showTalkDetails(BuildContext context, Talk talk) {
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
                if (talk.nextId != null && talk.nextId!.isNotEmpty) Text('Prossimo ID: ${talk.nextId}'),
                if (talk.watchNextTitle != null && talk.watchNextTitle!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Guarda Anche:'),
                      ...talk.watchNextTitle!.map((title) => Text(' - $title')).toList(),
                    ],
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              // AGGIUNTO QUI: Il pulsante "Chiudi" sarà rosso
              style: TextButton.styleFrom(
                foregroundColor: AppColors.tedxRed, // Colore del testo rosso
              ),
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