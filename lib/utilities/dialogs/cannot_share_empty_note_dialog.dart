import 'package:flutter/material.dart';
import 'package:mynote/utilities/dialogs/genereic_dialog.dart';

Future<void> cannotShareEmptyNoteDialog(BuildContext context) {
  return showGenirecDialog(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty note. Please add some text to the note before sharing.',
    optionsBuilder:() => {
      'OK': null,
    },
  );
}
