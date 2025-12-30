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
        body: Center(child: Text("Usuario no autenticado")),
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
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Scaffold(
            body: Center(child: Text("No hay datos del usuario")),
          );
        }

        final data = Map<String, dynamic>.from(
          snapshot.data!.snapshot.value as Map,
        );

        final String nombreCompleto = "${data['nombre']} ${data['apellido']}";

        return Scaffold(
          appBar: AppBar(title: Text(nombreCompleto)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _fotoPerfil(context, data['foto'], user.uid),

                const SizedBox(height: 20),

                _item("Cedula", data['cedula'], context),
                _item("Nombre", data['nombre'], context),
                _item("Apellido", data['apellido'], context),
                _item("Edad", data['edad'], context),
                _item("Email", data['email'], context),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text("Eliminar cuenta"),
                  onPressed: () => eliminarCuenta(context),
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
          key: ValueKey(fotoUrl), // 🔥 fuerza rebuild cuando cambia la URL
          radius: 60,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: fotoUrl != null && fotoUrl.isNotEmpty
              ? NetworkImage(fotoUrl)
              : null,
          child: fotoUrl == null || fotoUrl.isEmpty
              ? const Icon(Icons.person, size: 60)
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Cámara"),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(context, uid, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Galería"),
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
        child: ListTile(
          title: Text(titulo),
          subtitle: Text(
            valor,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      title: Text("Editar $titulo"),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: titulo,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
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
