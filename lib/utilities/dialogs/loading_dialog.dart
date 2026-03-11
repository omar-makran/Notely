import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef CloseDialog = void Function();

CloseDialog showLoadingDialog({
  required BuildContext context,
  String text = 'Please wait, while loading...',
}) {
  final dialog = Platform.isIOS
      ? const Center(
          child: CupertinoActivityIndicator(
            radius: 15.0,
            color: Color.fromARGB(224, 255, 174, 0),
          ),
        )
      : const Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(224, 255, 174, 0),
          ),
        );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => dialog,
  );

  return () {
    Navigator.of(context, rootNavigator: true).pop();
  };
}
