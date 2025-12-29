import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MiPerfil extends StatelessWidget {
  const MiPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Usuario no autenticado")),
      );
    }

    final DatabaseReference ref = FirebaseDatabase.instance.ref(
      "usuarios/${user.uid}",
    );

    return StreamBuilder<DatabaseEvent>(
      stream: ref.onValue, // escucha cambios en tiempo real
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

        // Combina nombre y apellido para el AppBar
        String nombreCompleto = "${data['nombre']} ${data['apellido']}";

        return Scaffold(
          appBar: AppBar(title: Text(nombreCompleto)),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _item("Cedula", data['cedula'], context),
                _item("Nombre", data['nombre'], context),
                _item("Apellido", data['apellido'], context),
                _item("Edad", data['edad'], context),
                _item("Email", data['email'], context),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text("Eliminar cuenta"),
                  onPressed: () {
                    eliminarCuenta(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                      uid: FirebaseAuth.instance.currentUser!.uid,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

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

Future<void> eliminarCuenta(BuildContext context) async {
  try {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final String uid = user.uid;

    // 1️⃣ Eliminar de Realtime Database
    await FirebaseDatabase.instance.ref("usuarios/$uid").remove();

    // 2️⃣ Cerrar sesión explícitamente
    await FirebaseAuth.instance.signOut();

    // 3️⃣ Eliminar usuario
    await user.delete();

    // 🚫 NO navegación aquí
    // AuthGate se encarga solo
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Error al eliminar cuenta. Inicia sesión de nuevo."),
      ),
    );
    debugPrint("Error eliminar cuenta: $e");
  }
}
