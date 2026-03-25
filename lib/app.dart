import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/config/app_theme.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/services/auth/bloc/auth_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/views/home_page.dart';
import 'package:mynote/views/notes/create_update_note.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final provider = AuthService.firebase();
        AuthBloc authBloc = AuthBloc(provider);
        authBloc.add(const AuthEventInitialize());
        return authBloc;
      },
      child: MaterialApp(
        title: 'Notely',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        home: const HomePage(),
        routes: {'/notes/new-note': (context) => const CreateUpdateNoteView()},
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
