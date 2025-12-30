import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "ONEFLIX",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: formulario(context),
    );
  }
}

Widget formulario(context) {
  TextEditingController correo = TextEditingController();
  TextEditingController contrasenia = TextEditingController();

  return Stack(
    children: [
      SizedBox.expand(
        child: Image.asset(
          "assets/images/one.jpg", // tu imagen de fondo
          fit: BoxFit.cover,
        ),
      ),
      Container(
        color: Colors.black.withOpacity(0.6), // overlay oscuro
      ),
      Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Inicia sesión para continuar",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: correo,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Correo",
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white38),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.redAccent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contrasenia,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white38),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.redAccent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () => login(context, correo, contrasenia),
                    child: const Text(
                      "INGRESAR",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => recuperarContrasena(context, correo),
                  child: const Text(
                    "¿Olvidaste la contraseña?",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

Future<void> login(context, correo, contrasenia) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: correo.text.trim(),
      password: contrasenia.text.trim(),
    );

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
    await FirebaseAuth.instance.sendPasswordResetEmail(email: correo.text.trim());
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
