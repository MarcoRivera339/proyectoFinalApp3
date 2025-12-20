import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:proyecto/navigations/Drawer.dart';

class Movieslist extends StatelessWidget {
  const Movieslist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Peliculas")),
      drawer: MyDrawer(),
      body: listaPeliculas(context),
    );
  }
}

// funcion lista traer una lista
Future<List<dynamic>> leerLista(context) async {
  final jsonString = await DefaultAssetBundle.of(
    context,
  ).loadString("data/peliculas.json");
  return json.decode(jsonString)['categorias'];
}

// widget para ver la lista
Widget listaPeliculas(context) {
  return FutureBuilder(
    future: leerLista(context),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        List data = snapshot.data!;

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];

            // peliculas es una LISTA
            List peliculas = item['peliculas'];

            // Tomo una película usando el index (sin for y sin [0] fijo)
            int pos = index;
            if (pos >= peliculas.length) {
              pos = 0;
            }
            final pelicula = peliculas[pos];

            return ListTile(
              title: Text(item['nombre']),
              subtitle: Column(
                children: [
                  Text(pelicula['titulo']),
                  GestureDetector(
                    onTap: () {
                      String respuesta =
                          "ID: ${pelicula['id']}\n"
                          "Título: ${pelicula['titulo']}\n"
                          "Descripción: ${pelicula['descripcion']}";
                      mensaje(context, respuesta);
                    },
                    child: Image.network(pelicula['imagen']),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        return Text("No hay data");
      }
    },
  );
}

// ALERTA (función tipo la que te enseñaron)
void mensaje(context, respuesta) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("PELICULA"),
        content: Text(respuesta),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Aceptar"),
          ),
        ],
      );
    },
  );
}
