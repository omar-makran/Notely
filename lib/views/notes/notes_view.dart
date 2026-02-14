import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/services/crud/notes_service.dart';

import '../../enums/menu_action.dart';
import '../../utilities/show_logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {

  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;
  
  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
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
              icon: const Icon(Icons.add)
              ),
              _buildAppBarActions()
          ],
      ),
      // Android: Floating Action Button (native Material pattern)
      floatingActionButton: Platform.isIOS ? null : FloatingActionButton(
        onPressed: _navigateToNewNote,
        child: Icon(Icons.add),),
      body: FutureBuilder(
        future: _notesService.createUser(email: userEmail),
        builder:(context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Text("Waiting for all notes...");
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