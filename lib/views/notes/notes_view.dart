import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/services/auth/bloc/auth_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/services/cloud/cloud_note.dart';
import 'package:mynote/services/cloud/firebase_cloud_storage.dart';
import 'package:mynote/utilities/dialogs/genereic_dialog.dart';
import 'package:mynote/views/notes/notes_list_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import '../../enums/menu_action.dart';
import '../../utilities/dialogs/show_logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showLogOutDialog(context);
    if (shouldLogout) {
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthEventLogOut());
    }
  }

  void _navigateToNewNote() {
    Navigator.of(context).pushNamed('/notes/new-note');
  }

  Widget _buildAppBarActions() {
    if (Platform.isIOS) {
      return IconButton(
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (context) => CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _handleLogout();
                  },
                  isDestructiveAction: true,
                  child: const Text('Log out'),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ),
          );
        },
        icon: const Icon(Icons.more_horiz),
      );
    } else {
      return PopupMenuButton<MenuAction>(
        onSelected: (value) async {
          switch (value) {
            case MenuAction.logout:
              await _handleLogout();
              break;
          }
        },
        itemBuilder: (context) {
          return const [
            PopupMenuItem<MenuAction>(
              value: MenuAction.logout,
              child: Text('Log out'),
            ),
          ];
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          _buildAppBarActions(),
        ],
      ),
      floatingActionButton: Platform.isIOS
          ? IconButton(
              onPressed: _navigateToNewNote,
              icon: const Icon(CupertinoIcons.square_pencil, size: 36),
              color: Theme.of(context).colorScheme.primary,
            )
          : FloatingActionButton(
              onPressed: _navigateToNewNote,
              child: const Icon(Icons.add),
            ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                if (allNotes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 80,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(120),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notes yet',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to create your first note',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  );
                }
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNotes(
                      documentId: note.documentId,
                    );
                  },
                  onShareNote: (CloudNote note) async {
                    await SharePlus.instance.share(
                      ShareParams(text: note.text),
                    );
                  },
                  onCopyNote: (CloudNote note) async {
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(ClipboardData(text: note.text));
                    if (!mounted) return;
                    if (Platform.isIOS) {
                      if (!context.mounted) return;
                      showGenirecDialog(
                        context: context,
                        title: 'Copied',
                        content: 'Copied to clipboard!',
                        optionsBuilder: () => {'Ok': null},
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard!')),
                      );
                    }
                  },
                  onTap: (note) {
                    Navigator.of(
                      context,
                    ).pushNamed('/notes/new-note', arguments: note);
                  },
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
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
