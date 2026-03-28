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
          child: Container(
            color: Colors.black.withAlpha(100),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200, minWidth: 200),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      StreamBuilder<String>(
                        stream: textStream.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  ),
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
