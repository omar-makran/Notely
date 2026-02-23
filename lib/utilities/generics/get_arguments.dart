import 'package:flutter/cupertino.dart';

extension GetArgument on BuildContext {
  T? getArgument<T>() {
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args != null && args is T) {
      return args as T;
    } else {
      return null;
    }
  }
}
