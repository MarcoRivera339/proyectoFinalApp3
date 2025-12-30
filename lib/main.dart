import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/firebase_options.dart';
import 'package:proyecto/navigations/Bottomtabnavigator.dart';
import 'package:proyecto/screens/homeScreen.dart';
import 'package:proyecto/screens/loginScreen.dart';
import 'package:proyecto/screens/perfilScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://xiyamkzutmocckoixuyn.supabase.co',
    anonKey: 'sb_publishable_bo5mmcASmYr41NtLFozeyA_op62_sM2',
  );
  runApp(const Proyecto());
}

final supabase = Supabase.instance.client;

class Proyecto extends StatelessWidget {
  const Proyecto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/home": (context) => const Homescreen(),
        "/login": (context) => const LoginScreen(),
        "/perfil": (context) => const MiPerfil(),
      },
      debugShowCheckedModeBanner: false,

      home: StreamBuilder<firebase_auth.User?>(
        stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // ⏳ Esperando Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const Bottomtabnavigator();
          }
          return const Homescreen();
        },
      ),
    );
  }
}
