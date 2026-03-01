import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mynote/services/cloud/cloud_note.dart';
import 'package:mynote/utilities/dialogs/show_delete_dialog.dart';

typedef DeleteNoteCallBack = void Function(CloudNote note);
typedef ShareNoteCallBack = void Function(CloudNote note);
typedef CopyNoteCallBack = void Function(CloudNote note);
typedef NoteTapCallBack = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final DeleteNoteCallBack onDeleteNote;
  final ShareNoteCallBack onShareNote;
  final CopyNoteCallBack onCopyNote;
  final NoteTapCallBack onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onShareNote,
    required this.onCopyNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.toList().length,
      itemBuilder: (context, index) {
        final note = notes.toList()[index];
        return ListTile(
          onTap: () {
            onTap(note);
          },
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
