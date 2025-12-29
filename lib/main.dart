import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/firebase_options.dart';
import 'package:proyecto/navigations/Bottomtabnavigator.dart';
import 'package:proyecto/screens/homeScreen.dart';
import 'package:proyecto/screens/loginScreen.dart';
import 'package:proyecto/screens/perfilScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Proyecto());
}

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

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
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
