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

  void cambiarFoto(XFile? nuevaFoto) {
    if (nuevaFoto == null) return;
    setState(() {
      foto = nuevaFoto;
    });
  }

  final cedula = TextEditingController();
  final nombre = TextEditingController();
  final apellido = TextEditingController();
  final edad = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _campo("Cédula", cedula, TextInputType.number),
            _campo("Nombre", nombre),
            _campo("Apellido", apellido),
            _campo("Edad", edad, TextInputType.number),
            _campo("Email", email, TextInputType.emailAddress),
            _campo("Contraseña", password, TextInputType.text, true),
            const SizedBox(height: 20),
            foto == null
                ? const CircleAvatar(
                    radius: 60,
                    child: Icon(Icons.person, size: 60),
                  )
                : CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(File(foto!.path)),
                  ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () => abrirCamara(cambiarFoto),
                ),
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: () => abrirGaleria(cambiarFoto),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text("Registrar"),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController controller, [
    TextInputType tipo = TextInputType.text,
    bool oculto = false,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        obscureText: oculto,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🔐 REGISTRO
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
    // 1️⃣ Crear usuario en Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email.text.trim(),
      password: password.text.trim(),
    );

    String uid = userCredential.user!.uid;

    // 2️⃣ Subir imagen a Supabase (opcional)
    String fotoUrl = "";
    if (foto != null) {
      try {
        fotoUrl = await subirImagenSupabase(foto) ?? "";
      } catch (e) {
        print("⚠️ Error subiendo imagen: $e");
      }
    }

    // 3️⃣ Guardar datos en Realtime Database
    DatabaseReference ref = FirebaseDatabase.instance.ref("usuarios/$uid");
    await ref.set({
      "cedula": cedula.text,
      "nombre": nombre.text,
      "apellido": apellido.text,
      "edad": edad.text,
      "email": email.text,
      "foto": fotoUrl,
    });

    // 4️⃣ Mostrar diálogo de confirmación
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Registro exitoso"),
        content: const Text("La cuenta ha sido creada correctamente."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );

    // 5️⃣ Cerrar sesión y volver al Home
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);

  } catch (e) {
    print("❌ Error registro: $e");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(content: Text("Error al registrar usuario")),
    );
  }
}

////////////////////////////////////////////////////////////
/// ☁️ SUBIR IMAGEN A SUPABASE
////////////////////////////////////////////////////////////

Future<String?> subirImagenSupabase(XFile foto) async {
  final file = File(foto.path);
  final fileName = 'usuarios/${DateTime.now().millisecondsSinceEpoch}.png';
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
