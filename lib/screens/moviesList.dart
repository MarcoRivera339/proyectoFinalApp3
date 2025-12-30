import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:proyecto/screens/youtube_trailer_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'video_player_screen.dart';

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

  Future<Map<String, dynamic>> leerCategorias(BuildContext context) async {
    final jsonString = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/peliculas.json');

    final Map<String, dynamic> data = json.decode(jsonString);
    return Map<String, dynamic>.from(data['categorias']);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: leerCategorias(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Error al cargar películas'));
        }

        final categorias = snapshot.data!;

        return ListView(
          children: categorias.entries.map((entry) {
            final String nombreCategoria = entry.key;
            final List peliculas = List<Map<String, dynamic>>.from(
              entry.value['peliculas'],
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📌 TÍTULO DE LA CATEGORÍA
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    nombreCategoria,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // 🎬 PELÍCULAS DE LA CATEGORÍA
                ...peliculas.map((pelicula) {
                  final peli = Map<String, dynamic>.from(pelicula);

                  return ListTile(
                    leading: Image.network(
                      peli['imagen'],
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.movie),
                    ),
                    title: Text(peli['titulo']),
                    subtitle: Text('${peli['genero']} • ${peli['anio']}'),
                    onTap: () => mostrarInfo(context, peli),
                  );
                }).toList(),

                const Divider(thickness: 1),
              ],
            );
          }).toList(),
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
            Image.network(
              pelicula['imagen'],
              errorBuilder: (_, __, ___) => const Icon(Icons.movie, size: 100),
            ),
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
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text("Reproducir película"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoPlayerScreen(videoUrl: pelicula['video']),
              ),
            );
          },
        ),

        ElevatedButton.icon(
  icon: const Icon(Icons.movie),
  label: const Text("Ver tráiler"),
  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
  onPressed: () {
    Navigator.pop(context); // cierra el AlertDialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            YoutubeTrailerScreen(url: pelicula['trailer']),
      ),
    );
  },
),


        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

Future<void> abrirTrailer(String url) async {
  final Uri uri = Uri.parse(url);

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'No se pudo abrir el trailer';
  }
}
