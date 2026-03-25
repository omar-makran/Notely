import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mynote/helpers/loading/loading_screen_controller.dart';

class LoadingScreen {
  LoadingScreen._();
  static final LoadingScreen _instance = LoadingScreen._();
  factory LoadingScreen() => _instance;
  LoadingScreenController? _controller;

  void hide() {
    _controller?.close();
    _controller = null;
  }

  void show({required BuildContext context, required String text}) {
    if (_controller != null) {
      _controller!.update(text);
      return;
    } else {
      _controller = _showOverlay(context: context, text: text);
    }
  }

  LoadingScreenController _showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final textStream = StreamController<String>();
    textStream.add(text);
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    StreamBuilder<String>(
                      stream: textStream.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(snapshot.data!);
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(overlayEntry);
    return LoadingScreenController(
      close: () {
        textStream.close();
        overlayEntry.remove();
      },
      update: (text) {
        textStream.add(text);
      },
    );
  }
}
