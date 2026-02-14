import 'package:flutter/material.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNotes? _note;
  late final NotesService _notesService;
  late final TextEditingController _textConteroller;

  @override
  void initState() {
    _notesService = NotesService();
    _textConteroller = TextEditingController();
    super.initState();
  }

  void  _textControllerListner() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textConteroller.text;
    await _notesService.updateNote(note: note, text: text);
  }

  void _setUpTextControllerListner() {
    _textConteroller.removeListener(_textControllerListner);
    _textConteroller.addListener(_textControllerListner);
  }

  Future<DatabaseNotes> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNotes(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (note != null && _textConteroller.text.isEmpty) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextIsNotEmpty() {
    final note = _note;
    final text = _textConteroller.text;
    if (note != null && text.isNotEmpty) {
      _notesService.updateNote(note: note, text: text);
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
            title: const Text('New Note'),
        ),
        body: FutureBuilder(
          future: createNewNote(),
          builder:(context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.hasData) {
                  _note = snapshot.data as DatabaseNotes;
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