import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/counter_bloc.dart';
import 'package:mynote/counter_event.dart';
import 'package:mynote/counter_state.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/views/login_view.dart';
import 'package:mynote/views/notes/create_update_note.dart';
import 'package:mynote/views/notes/notes_view.dart';
import 'package:mynote/views/register_view.dart';
import 'package:mynote/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'myNote',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
        '/verify-email/': (context) => const VerifyEmailView(),
        '/notes/': (context) => const NotesView(),
        '/notes/new-note': (context) => const CreateUpdateNoteView(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: AuthService.firebase().initializer(),
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.done:
//             return StreamBuilder(
//               stream: AuthService.firebase().authStateChanges,
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   final user = AuthService.firebase().currentUser;
//                   if (user?.isEmailVerified ?? false) {
//                     return const NotesView();
//                   } else {
//                     return const VerifyEmailView();
//                   }
//                 } else {
//                   return const LoginView();
//                 }
//               },
//             );
//           default:
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//         }
//       },
//     );
//   }
// }
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Counter App')),
        body: BlocConsumer<CounterBloc, CounterState>(
          builder: (context, state) {
            return Column(
              children: [
                TextField(
                  controller: _textController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Enter a number',
                  ),
                ),
                if (state is CounterStateInvalid)
                  Text(
                    'Invalid counter value: ${state.value}',
                    style: const TextStyle(fontSize: 20, color: Colors.red),
                  ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(IncrementEvent());
                      },
                      child: const Text('Increment'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(DecrementEvent());
                      },
                      child: const Text('Decrement'),
                    ),
                  ],
                ),
              ],
            );
          },
          listener: (context, state) {
            _textController.text = state.value.toString();
            // "When the counter changes, update the text field"
          },
        ),
      ),
    );
  }
}
