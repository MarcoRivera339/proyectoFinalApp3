import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Registerscreen extends StatefulWidget {
  const Registerscreen({super.key});

  @override
  State<Registerscreen> createState() => _RegisterscreenState();
}

class _RegisterscreenState extends State<Registerscreen> {
  XFile? foto;

  final cedula = TextEditingController();
  final nombre = TextEditingController();
  final apellido = TextEditingController();
  final edad = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  void cambiarFoto(XFile? nuevaFoto) {
    if (nuevaFoto == null) return;
    setState(() => foto = nuevaFoto);
  }

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
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/images/one.jpg", fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.7)),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Crea tu cuenta en ONEFLIX",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _campo("Cédula", cedula, Icons.badge),
                _campo("Nombre", nombre, Icons.person),
                _campo("Apellido", apellido, Icons.person),
                _campo("Edad", edad, Icons.cake),
                _campo("Email", email, Icons.email),
                _campo("Contraseña", password, Icons.lock, oculto: true),
                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white24,
                  backgroundImage: foto != null
                      ? FileImage(File(foto!.path))
                      : null,
                  child: foto == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () => abrirCamara(cambiarFoto),
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo, color: Colors.white),
                      onPressed: () => abrirGaleria(cambiarFoto),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () => register(
                      context,
                      cedula,
                      nombre,
                      apellido,
                      edad,
                      email,
                      password,
                      foto,
                    ),
                    child: const Text(
                      "REGISTRARSE",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "¿Ya tienes una cuenta? Inicia sesión",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool oculto = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: oculto,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white38),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🔐 REGISTRO CONTROLADO POR AUTH
////////////////////////////////////////////////////////////

Future<void> register(
  BuildContext context,
  TextEditingController cedula,
  TextEditingController nombre,
  TextEditingController apellido,
  TextEditingController edad,
  TextEditingController email,
  TextEditingController password,
  XFile? foto,
) async {
  try {
    final credenciales = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );

    final uid = credenciales.user!.uid;

    String fotoUrl = "";
    if (foto != null) {
      fotoUrl = await subirImagenSupabase(foto);
    }

    await FirebaseDatabase.instance.ref("usuarios/$uid").set({
      "cedula": cedula.text.trim(),
      "nombre": nombre.text.trim(),
      "apellido": apellido.text.trim(),
      "edad": edad.text.trim(),
      "email": email.text.trim(),
      "foto": fotoUrl,
    });

    // 🔑 CLAVE ABSOLUTA
    // Regresa a la raíz para que authStateChanges actúe
    Navigator.of(context).popUntil((route) => route.isFirst);
  } on FirebaseAuthException catch (e) {
    String mensaje = "Error al registrar usuario";

    if (e.code == 'email-already-in-use') {
      mensaje = "Este correo ya está registrado";
    } else if (e.code == 'weak-password') {
      mensaje = "La contraseña es muy débil";
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }
}

////////////////////////////////////////////////////////////
/// ☁️ SUPABASE
////////////////////////////////////////////////////////////

Future<String> subirImagenSupabase(XFile foto) async {
  final file = File(foto.path);
  final fileName = "usuarios/${DateTime.now().millisecondsSinceEpoch}.png";

  await Supabase.instance.client.storage
      .from('appMovie')
      .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

  return Supabase.instance.client.storage
      .from('appMovie')
      .getPublicUrl(fileName);
}

////////////////////////////////////////////////////////////
/// 📸 IMAGE PICKER
////////////////////////////////////////////////////////////

Future<void> abrirCamara(Function(XFile?) cambiarFoto) async {
  final imagen = await ImagePicker().pickImage(source: ImageSource.camera);
  cambiarFoto(imagen);
}

Future<void> abrirGaleria(Function(XFile?) cambiarFoto) async {
  final imagen = await ImagePicker().pickImage(source: ImageSource.gallery);
  cambiarFoto(imagen);
}
