import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/services/cloud/cloud_note.dart';
import 'package:mynote/services/cloud/firebase_cloud_storage.dart';
import 'package:mynote/utilities/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textConteroller;
  bool _hasText = false;
  late final Future<CloudNote> _noteFuture;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textConteroller = TextEditingController();
    super.initState();
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year at $hour:$minute';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _noteFuture = createOrGetExistingNote().then((note) {
      if (mounted && _textConteroller.text.isNotEmpty && !_hasText) {
        setState(() {
          _hasText = true;
        });
      }
      return note;
    });
  }

  void _textControllerListner() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textConteroller.text;
    final hasText = text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    if (text != note.text) {
      await _notesService.updateNotes(documentId: note.documentId, text: text);
    }
  }

  void _setUpTextControllerListner() {
    _textConteroller.removeListener(_textControllerListner);
    _textConteroller.addListener(_textControllerListner);
  }

  Future<CloudNote> createOrGetExistingNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textConteroller.text = widgetNote.text;
      _hasText = widgetNote.text.isNotEmpty;
      return widgetNote;
    } else {
      final currentUser = AuthService.firebase().currentUser!;
      final userId = currentUser.id;
      final newNote = await _notesService.createNewNote(ownerUserId: userId);
      _note = newNote;
      return newNote;
    }
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (note != null && _textConteroller.text.isEmpty) {
      _notesService.deleteNotes(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextIsNotEmpty() {
    final note = _note;
    final text = _textConteroller.text;
    if (note != null && text.isNotEmpty && text != note.text) {
      _notesService.updateNotes(documentId: note.documentId, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textConteroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Platform.isIOS
            ? Padding(
                padding: const EdgeInsets.all(6.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withAlpha(150),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withAlpha(50),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(CupertinoIcons.back, size: 24),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              )
            : null,
        actions: [
          AnimatedOpacity(
            opacity: _hasText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: !_hasText,
              child: Platform.isIOS
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withAlpha(150),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withAlpha(50),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              onPressed: () {
                                final text = _textConteroller.text;
                                if (text.isNotEmpty) {
                                  SharePlus.instance.share(ShareParams(text: text));
                                }
                              },
                              icon: const Icon(CupertinoIcons.share, size: 24),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        final text = _textConteroller.text;
                        if (text.isNotEmpty) {
                          SharePlus.instance.share(ShareParams(text: text));
                        }
                      },
                      icon: const Icon(Icons.share),
                    ),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _noteFuture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.hasData) {
                _note = snapshot.data as CloudNote;
                _setUpTextControllerListner();
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _formatDateTime(_note?.updatedAt),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: TextField(
                          controller: _textConteroller,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          cursorHeight: 22,
                          cursorWidth: 2.5,
                          cursorRadius: const Radius.circular(2),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 18,
                                height: 1.6,
                                letterSpacing: 0.2,
                              ),
                          decoration: InputDecoration(
                            hintText: 'Start writing your note...',
                            border: InputBorder.none,
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontSize: 18,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(150),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('Could not create note.'));
              }
            default:
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
