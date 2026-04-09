import 'dart:io';
import 'dart:ui';

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
      return Padding(
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
                icon: const Icon(CupertinoIcons.ellipsis, size: 24),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
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
      floatingActionButton: Platform.isIOS
          ? ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withAlpha(150),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withAlpha(50),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    onPressed: _navigateToNewNote,
                    icon: const Icon(CupertinoIcons.square_pencil, size: 32),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            )
          : FloatingActionButton(
              onPressed: _navigateToNewNote,
              child: const Icon(Icons.add),
            ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          Widget content;

          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              final allNotes = snapshot.data as Iterable<CloudNote>;
              if (allNotes.isEmpty) {
                content = SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.doc_text_search,
                          size: 100,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(80),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No notes found',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Platform.isIOS
                              ? 'Tap the pencil icon to create your first note\nand start capturing your thoughts.'
                              : 'Tap + to create your first note\nand start capturing your thoughts.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                content = NotesListView(
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
              }
            } else {
              content = SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              );
            }
          } else {
            content = SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text('Your Notes'),
                actions: [_buildAppBarActions()],
              ),
              content,
            ],
          );
        },
      ),
    );
  }
}
