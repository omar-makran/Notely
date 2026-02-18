import 'package:flutter/material.dart';
import 'package:mynote/utilities/dialogs/genereic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenirecDialog(
    context: context,
    title: 'An error accurred',
    content: text,
    optionsBuilder:() => {
      'OK': null,
    },
  );
}
