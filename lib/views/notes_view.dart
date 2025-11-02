import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utilities/show_logout_dialog.dart';

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {

  Future<void> _handleLogout() async {
    final shouldLogout = await showLogOutDialog(context);
    if (shouldLogout) {
      if (!mounted) return;
      await FirebaseAuth.instance.signOut();
    }
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
        title: const Text('Notes'),
        actions: [_buildAppBarActions()],
      ),
      body: const Center(
        child: Text('Notes View'),
      ),
    );
  }
}