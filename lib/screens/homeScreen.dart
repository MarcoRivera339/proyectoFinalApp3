import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/screens/loginScreen.dart';
import 'package:proyecto/screens/registerScreen.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("ONEFLIX"),
        actions: [
          // Botón para cerrar sesión
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, "/home");
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset("images/oneflixC.png", fit: BoxFit.cover),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Entretenimiento de calidad"),
                SizedBox(
                  width: 220,
                  height: 50,
                  child: FilledButton(
                    onPressed: () {
                      irLogin(context);
                    },
                    child: Text("Login"),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 220,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      irRegister(context);
                    },
                    child: const Text("REGISTER"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void irLogin(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
  );
}

void irRegister(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Registerscreen()),
  );
}
