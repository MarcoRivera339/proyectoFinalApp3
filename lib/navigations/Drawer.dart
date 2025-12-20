import 'package:flutter/material.dart';
import 'package:proyecto/main.dart';
import 'package:proyecto/screens/loginScreen.dart';
import 'package:proyecto/screens/moviesList.dart';
import 'package:proyecto/screens/registerScreen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ONEFLIX",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Proyecto()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.login),
            title: const Text("Login"),
            onTap: () {
              Navigator.pop(context); // cerrar drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Loginscreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.login),
            title: const Text("Register"),
            onTap: () {
              Navigator.pop(context); // cerrar drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Registerscreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.login),
            title: const Text("Movies"),
            onTap: () {
              Navigator.pop(context); // cerrar drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Movieslist()),
              );
            },
          ),
        ],
      ),
    );
  }
}
