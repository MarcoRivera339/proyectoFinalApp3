import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/screens/loginScreen.dart';
import 'package:proyecto/screens/registerScreen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  late final Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        // ⏳ Esperando Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔐 Usuario logueado → Drawer
        if (snapshot.hasData) {
          return const Scaffold(
            drawer: Drawer(),
            body: Center(child: Text("Usuario logueado")),
          );
        }

        // 👤 Usuario NO logueado → Home público
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(title: const Text("ONEFLIX")),
          body: Stack(
            children: [
              SizedBox.expand(
                child: Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    "assets/images/one.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Entretenimiento de calidad",
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: 220,
                      height: 50,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginScreen(),
                            ),
                          );
                        },
                        child: const Text("Login"),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: 220,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Registerscreen()),
                          );
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
      },
    );
  }
}
