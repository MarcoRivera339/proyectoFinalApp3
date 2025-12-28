import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/firebase_options.dart';
import 'package:proyecto/screens/homeScreen.dart';
import 'package:proyecto/screens/loginScreen.dart';
import 'package:proyecto/screens/moviesList.dart';
import 'package:proyecto/screens/registerScreen.dart';

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
      debugShowCheckedModeBanner: true,
      //rutas
      routes: {
        "/login": (context) => LoginScreen(),
        "/registro": (context) => Registerscreen(),
        "/drawer": (context) => Drawer(),
        "/moviesList": (context) => Movieslist(),
        "/home": (context) => Homescreen(),
      },

      home: Homescreen(),
    );
  }
}