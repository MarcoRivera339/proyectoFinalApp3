import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Registerscreen extends StatefulWidget {
  const Registerscreen({super.key});

  @override
  State<Registerscreen> createState() => _RegisterscreenState();
}

class _RegisterscreenState extends State<Registerscreen> {
  TextEditingController cedula = TextEditingController();
  TextEditingController nombre = TextEditingController();
  TextEditingController apellido = TextEditingController();
  TextEditingController edad = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: cedula,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Ingresa tu cedula"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: nombre,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Ingresa tu nombre"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: apellido,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Ingresa tu apellido"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: edad,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Ingresa tu edad"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: email,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Ingresa tu email"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: password,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Ingresa tu contrasenia"),
              ),
            ),
          ),

          ElevatedButton.icon(
            onPressed: () => register(
              context,
              cedula,
              nombre,
              apellido,
              edad,
              email,
              password,
            ),
            label: Text("Register"),
            icon: Icon(Icons.monitor_weight_rounded),
          ),
        ],
      ),
    );
  }
}

Future<void> register(
  context,
  cedula,
  nombre,
  apellido,
  edad,
  email,
  password,
) async {
  try {
    // 1. Creamos el usuario
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );

    String uid = userCredential.user!.uid;

    // 2. Guardamos datos
    DatabaseReference ref = FirebaseDatabase.instance.ref("usuarios/$uid");
    await ref.set({
      "cedula": cedula.text,
      "nombre": nombre.text,
      "apellido": apellido.text,
      "edad": edad.text,
      "email": email.text,
    });

    // 3. CERRAR SESIÓN para que no entre directo
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signOut();

    // 4. Mostrar el diálogo
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Registro Exitoso"),
          content: const Text("Ahora inicia sesión con tu cuenta."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, "/login");
                Navigator.pop(context, "/login");
              },
              child: const Text("IR AL LOGIN"),
            ),
          ],
        );
      },
    );
  } catch (e) {
    print("Error: $e");
  }
}
