import 'dart:io';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Create the future ONCE, not on every rebuild
    _noteFuture = createOrGetExistingNote().then((note) {
      // After the note loads, update the share icon visibility
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
        actions: [
          AnimatedOpacity(
            opacity: _hasText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: !_hasText,
              child: IconButton(
                onPressed: () {
                  final text = _textConteroller.text;
                  if (text.isNotEmpty) {
                    SharePlus.instance.share(ShareParams(text: text));
                  }
                },
                icon: Icon(Platform.isIOS ? CupertinoIcons.share : Icons.share),
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
                  child: TextField(
                    controller: _textConteroller,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Start writing your note...',
                      border: InputBorder.none,
                      hintStyle: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                    ),
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
