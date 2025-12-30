import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MiPerfil extends StatelessWidget {
  const MiPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final firebase_auth.User? user =
        firebase_auth.FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Usuario no autenticado",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final DatabaseReference ref = FirebaseDatabase.instance.ref(
      "usuarios/${user.uid}",
    );

    return StreamBuilder<DatabaseEvent>(
      stream: ref.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                "No hay datos del usuario",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final data = Map<String, dynamic>.from(
          snapshot.data!.snapshot.value as Map,
        );

        final String nombreCompleto = "${data['nombre']} ${data['apellido']}";

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black87,
            title: Text(
              nombreCompleto,
              style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 1.5),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _fotoPerfil(context, data['foto'], user.uid),

                const SizedBox(height: 30),

                _item("Cédula", data['cedula'], context),
                _item("Nombre", data['nombre'], context),
                _item("Apellido", data['apellido'], context),
                _item("Edad", data['edad'], context),
                _item("Email", data['email'], context),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.delete_forever),
                    label: const Text(
                      "Eliminar cuenta",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => eliminarCuenta(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔵 FOTO PERFIL + EDICIÓN
  Widget _fotoPerfil(BuildContext context, String? fotoUrl, String uid) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          key: ValueKey(fotoUrl),
          radius: 60,
          backgroundColor: Colors.white12,
          backgroundImage: fotoUrl != null && fotoUrl.isNotEmpty
              ? NetworkImage(fotoUrl)
              : null,
          child: fotoUrl == null || fotoUrl.isEmpty
              ? const Icon(Icons.person, size: 60, color: Colors.white70)
              : null,
        ),
        FloatingActionButton(
          mini: true,
          backgroundColor: Colors.amber,
          onPressed: () => cambiarFoto(context, uid),
          child: const Icon(Icons.edit, color: Colors.black),
        ),
      ],
    );
  }

  /// 📸 CAMBIAR FOTO → SUPABASE → FIREBASE
  Future<void> cambiarFoto(BuildContext context, String uid) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text("Cámara", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(context, uid, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.white),
                title: const Text("Galería", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(context, uid, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🧾 ITEM DE PERFIL
  Widget _item(String titulo, String valor, BuildContext context) {
    final bool esNoEditable =
        titulo.toLowerCase() == "cedula" || titulo.toLowerCase() == "email";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
        child: ListTile(
          title: Text(
            titulo,
            style: const TextStyle(color: Colors.white70),
          ),
          subtitle: Text(
            valor,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          trailing: esNoEditable
              ? null
              : IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.amber,
                  onPressed: () {
                    editarCampo(
                      context: context,
                      titulo: titulo,
                      campo: titulo.toLowerCase(),
                      valorActual: valor,
                      uid: firebase_auth.FirebaseAuth.instance.currentUser!.uid,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

/// ✏️ EDITAR CAMPOS
void editarCampo({
  required BuildContext context,
  required String titulo,
  required String campo,
  required String valorActual,
  required String uid,
}) {
  final TextEditingController controller = TextEditingController(
    text: valorActual,
  );

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: Text(
        "Editar $titulo",
        style: const TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: titulo,
          labelStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () async {
            await FirebaseDatabase.instance.ref("usuarios/$uid").update({
              campo: controller.text.trim(),
            });
            Navigator.pop(context);
          },
          child: const Text("Guardar"),
        ),
      ],
    ),
  );
}

/// ❌ ELIMINAR CUENTA (ORDEN CORRECTO)
Future<void> eliminarCuenta(BuildContext context) async {
  try {
    final firebase_auth.User? user =
        firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final String uid = user.uid;

    await FirebaseDatabase.instance.ref("usuarios/$uid").remove();
    await user.delete();
    await firebase_auth.FirebaseAuth.instance.signOut();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Error al eliminar cuenta. Inicia sesión nuevamente."),
      ),
    );
    debugPrint("Error eliminar cuenta: $e");
  }
}

Future<void> _seleccionarImagen(
  BuildContext context,
  String uid,
  ImageSource source,
) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: source);

  if (image == null) return;

  try {
    final File file = File(image.path);
    final String filePath =
        'usuarios/$uid-${DateTime.now().millisecondsSinceEpoch}.jpg';

    // 1️⃣ Subir a Supabase
    await Supabase.instance.client.storage
        .from('appMovie')
        .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

    // 2️⃣ URL pública con timestamp (anti-cache)
    final String publicUrl =
        Supabase.instance.client.storage
            .from('appMovie')
            .getPublicUrl(filePath) +
        '?t=${DateTime.now().millisecondsSinceEpoch}';

    // 3️⃣ Guardar en Firebase
    await FirebaseDatabase.instance.ref("usuarios/$uid").update({
      "foto": publicUrl,
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error al actualizar la foto")),
    );
    debugPrint("Error subir foto: $e");
  }
}
