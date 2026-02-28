import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/services/crud/notes_service.dart';
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
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showLogOutDialog(context);
    if (shouldLogout) {
      if (!mounted) return;
      await AuthService.firebase().logOut();
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
          if (Platform.isIOS)
            IconButton(
              onPressed: _navigateToNewNote,
              icon: const Icon(Icons.add),
            ),
          _buildAppBarActions(),
        ],
      ),
      // Android: Floating Action Button (native Material pattern)
      floatingActionButton: Platform.isIOS
          ? null
          : FloatingActionButton(
              onPressed: _navigateToNewNote,
              child: Icon(Icons.add),
            ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNotes>;
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async {
                            await _notesService.deleteNote(id: note.id);
                          },
                          onShareNote: (DatabaseNotes note) async {
                            await SharePlus.instance.share(
                              ShareParams(text: note.text),
                            );
                          },
                          onCopyNote: (DatabaseNotes note) async {
                            await Clipboard.setData(
                              ClipboardData(text: note.text),
                            );
                            if (!mounted) return;
                            if (Platform.isIOS) {
                              showGenirecDialog(
                                context: context,
                                title: 'Copied',
                                content: 'Copied to clipboard!',
                                optionsBuilder: () => {'Ok': null},
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard!'),
                                ),
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
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
