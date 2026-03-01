import 'package:flutter/material.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/services/cloud/cloud_note.dart';
import 'package:mynote/services/cloud/firebase_cloud_storage.dart';
import 'package:mynote/utilities/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textConteroller;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textConteroller = TextEditingController();
    super.initState();
  }

  void _textControllerListner() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textConteroller.text;
    await _notesService.updateNotes(documentId: note.documentId, text: text);
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
    if (note != null && text.isNotEmpty) {
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
        title: Text(
          context.getArgument<CloudNote>() != null ? 'Edit Note' : 'New Note',
        ),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.hasData) {
                _note = snapshot.data as CloudNote;
                _setUpTextControllerListner();
                return TextField(
                  controller: _textConteroller,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "I have a meeting ...",
                  ),
                );
              } else {
                return const Center(child: Text('Could not create note.'));
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
