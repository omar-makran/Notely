import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Old note';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final notesList = notes.where((note) => note.text.trim().isNotEmpty).toList();

    notesList.sort((a, b) {
      final aDate = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return bDate.compareTo(aDate);
    });

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 100, top: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final note = notesList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Slidable(
                key: Key(note.documentId),
                endActionPane: ActionPane(
                  motion: const BehindMotion(),
                  extentRatio: 0.3,
                  children: [
                    CustomSlidableAction(
                      onPressed: (context) => onShareNote(note),
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Platform.isIOS ? CupertinoIcons.share : Icons.share,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomSlidableAction(
                      onPressed: (context) async {
                        final shouldDelete = await showDeleteDialog(context);
                        if (shouldDelete) {
                          onDeleteNote(note);
                        }
                      },
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withAlpha(40),
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onTap(note),
                      onLongPress: () => onCopyNote(note),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.text.split('\n').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2, // Premium tracking
                                  ),
                            ),
                            if (note.text.contains('\n') || note.text.length > 40) ...[
                              const SizedBox(height: 8),
                              Text(
                                note.text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      height: 1.4, // Line height for preview text
                                    ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Text(
                              _formatDate(note.updatedAt),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: notesList.length,
        ),
      ),
    );
  }
}
