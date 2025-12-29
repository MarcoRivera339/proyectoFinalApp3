import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto/screens/moviesList.dart';
import 'package:proyecto/screens/perfilScreen.dart';

class Bottomtabnavigator extends StatefulWidget {
  const Bottomtabnavigator({super.key});

  @override
  State<Bottomtabnavigator> createState() => _BottomtabnavigatorState();
}

class _BottomtabnavigatorState extends State<Bottomtabnavigator> {
  int _indiceActual = 0;

  final List<Widget> _pantallas = const [
    MiPerfil(),
    Movieslist(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ONEFLIX"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      body: _pantallas[_indiceActual],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (index) {
          setState(() {
            _indiceActual = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_box),label: 'Mi perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Películas'),
        ],
      ),
    );
  }
}
