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

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: correo,
          decoration: const InputDecoration(labelText: "Ingresar correo"),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: contrasenia,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Ingresar contraseña"),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => login(context, correo, contrasenia),
          icon: const Icon(Icons.login),
          label: const Text("Ingresar"),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => recuperarContrasena(context, correo),
          child: const Text("¿Olvidaste la contraseña?"),
        ),
      ],
    ),
  );
}

Future<void> login(context, correo, contrasenia) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: correo.text.trim(),
      password: contrasenia.text.trim(),
    );

    // 👇 ESTO ES LA CLAVE
    Navigator.pop(context);
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
      builder: (_) => AlertDialog(
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

// Función para recuperar contraseña
Future<void> recuperarContrasena(context, TextEditingController correo) async {
  if (correo.text.isEmpty) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Correo vacío"),
        content: const Text(
          "Por favor, ingresa tu correo para recuperar la contraseña.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
    return;
  }

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: correo.text.trim(),
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Correo enviado"),
        content: Text(
          "Se ha enviado un correo de recuperación a ${correo.text.trim()}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  } on FirebaseAuthException catch (e) {
    String mensaje = "Ocurrió un error inesperado";
    if (e.code == 'user-not-found') {
      mensaje = "No se encontró un usuario con ese correo.";
    } else if (e.code == 'invalid-email') {
      mensaje = "El formato del correo es inválido.";
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
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
