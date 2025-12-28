import 'dart:convert';
import 'package:flutter/material.dart';

class Movieslist extends StatelessWidget {
  const Movieslist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Películas')),
      body: const ListaPeliculas(),
    );
  }
}

class ListaPeliculas extends StatelessWidget {
  const ListaPeliculas({super.key});

  Future<List<Map<String, dynamic>>> leerPeliculas(BuildContext context) async {
    final jsonString = await DefaultAssetBundle.of(
      context,
    ).loadString('data/peliculas.json');

    final Map<String, dynamic> data = json.decode(jsonString);

    final Map<String, dynamic> peliculasMap = Map<String, dynamic>.from(
      data['peliculas'],
    );

    return peliculasMap.entries.map((entry) {
      return {"id": entry.key, ...Map<String, dynamic>.from(entry.value)};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: leerPeliculas(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar películas'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay películas'));
        }

        final peliculas = snapshot.data!;

        return ListView.builder(
          itemCount: peliculas.length,
          itemBuilder: (context, index) {
            final pelicula = peliculas[index];

            return ListTile(
              leading: Image.asset(
                pelicula['imagen'],
                width: 50,
                height: 70,
                fit: BoxFit.cover,
              ),
              title: Text(pelicula['titulo']),
              subtitle: Text('${pelicula['genero']} • ${pelicula['anio']}'),
              onTap: () => mostrarInfo(context, pelicula),
            );
          },
        );
      },
    );
  }
}

void mostrarInfo(BuildContext context, Map<String, dynamic> pelicula) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(pelicula['titulo']),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(pelicula['imagen']),
            const SizedBox(height: 10),
            Text('Género: ${pelicula['genero']}'),
            Text('Año: ${pelicula['anio']}'),
            Text('Duración: ${pelicula['duracion']}'),
            const SizedBox(height: 10),
            Text(pelicula['descripcion']),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}
