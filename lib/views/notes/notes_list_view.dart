import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mynote/services/crud/notes_service.dart';
import 'package:mynote/utilities/dialogs/show_delete_dialog.dart';

typedef DeleteNoteCallBack = void Function(DatabaseNotes note);
typedef ShareNoteCallBack = void Function(DatabaseNotes note);
typedef CopyNoteCallBack = void Function(DatabaseNotes note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNotes> notes;
  final DeleteNoteCallBack onDeleteNote;
  final ShareNoteCallBack onShareNote;
  final CopyNoteCallBack onCopyNote;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onShareNote,
    required this.onCopyNote,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          onLongPress: () {
            onCopyNote(note);
          },
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  final shouldDelete = await showDeleteDialog(context);
                  if (shouldDelete) {
                    onDeleteNote(note);
                  }
                },
                icon: const Icon(Icons.delete),
              ),
              IconButton(
                onPressed: () async {
                  onShareNote(note);
                },
                icon: Icon(Platform.isIOS ? CupertinoIcons.share : Icons.share),
              ),
            ],
          ),
        );
      },
    );
  }
}
