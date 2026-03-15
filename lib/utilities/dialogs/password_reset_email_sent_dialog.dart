import 'package:flutter/widgets.dart';
import 'package:mynote/utilities/dialogs/genereic_dialog.dart';

Future<void> showPasswordResetEmailSentDialog(
  BuildContext context,
  String text,
) {
  return showGenirecDialog(
    context: context,
    title: 'Password Reset Email Sent',
    content: text,
    optionsBuilder: () => {'OK': null},
  );
}
