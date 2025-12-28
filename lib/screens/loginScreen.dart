import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: formulario(context),
    );
  }
}

Widget formulario(context) {
  TextEditingController correo = TextEditingController();
  TextEditingController contrasenia = TextEditingController();

  return Column(
    children: [
      TextField(
        controller: correo,
        decoration: InputDecoration(label: Text("Ingresar correo")),
      ),

      TextField(
        controller: contrasenia,
        obscureText: true,
        decoration: InputDecoration(label: Text("Ingresar contrasenia")),
      ),

      FilledButton.icon(
        onPressed: () => login(context, correo, contrasenia),
        icon: const Icon(Icons.login),
        label: const Text("Ingresar"),
      ),
      FilledButton.icon(
        onPressed: () => Navigator.pushNamed(context, "/registro"),
        label: const Text("Registrate"),
        icon: const Icon(Icons.person_add),
      ),
    ],
  );
}

Future<void> login(
  BuildContext context,
  TextEditingController correo,
  TextEditingController contrasenia,
) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: correo.text.trim(),
      password: contrasenia.text.trim(),
    );

    Navigator.pushReplacementNamed(context, "/drawer");
  } on FirebaseAuthException catch (e) {
    String mensaje = "Ocurrió un error inesperado";

    if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
      mensaje = 'El correo o la contraseña no son correctos.';
    } else if (e.code == 'wrong-password') {
      mensaje = 'Contraseña incorrecta.';
    } else if (e.code == 'invalid-email') {
      mensaje = 'El formato del correo es inválido.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error de inicio de sesión"),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }
}
