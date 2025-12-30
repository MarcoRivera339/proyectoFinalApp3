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

  Future<void> cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          "ONEFLIX",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Cerrar sesión",
            onPressed: cerrarSesion,
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _pantallas[_indiceActual],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (index) => setState(() => _indiceActual = index),
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Mi perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Películas',
          ),
        ],
      ),
    );
  }
}
