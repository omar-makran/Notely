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
    final notesList = notes.toList();
    return ListView.builder(
      itemCount: notesList.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final note = notesList[index];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withAlpha(50),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onTap(note),
              onLongPress: () => onCopyNote(note),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () async {
                            final shouldDelete = await showDeleteDialog(
                              context,
                            );
                            if (shouldDelete) {
                              onDeleteNote(note);
                            }
                          },
                          icon: const Icon(Icons.delete_outline, size: 20),
                        ),
                        IconButton(
                          onPressed: () => onShareNote(note),
                          icon: Icon(
                            Platform.isIOS ? CupertinoIcons.share : Icons.share,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
