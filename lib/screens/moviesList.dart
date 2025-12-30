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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          'ONEFLIX',
          style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: const ListaPeliculas(),
    );
  }
}

class ListaPeliculas extends StatelessWidget {
  const ListaPeliculas({super.key});

  Future<Map<String, dynamic>> leerCategorias(BuildContext context) async {
    final jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/data/peliculas.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    return Map<String, dynamic>.from(data['categorias']);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: leerCategorias(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.redAccent),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Text(
              'Error al cargar películas',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final categorias = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    nombreCategoria,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),

                // 🎬 PELÍCULAS DE LA CATEGORÍA
                ...peliculas.map((pelicula) {
                  final peli = Map<String, dynamic>.from(pelicula);

                  return Card(
                    color: Colors.grey.shade900,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          peli['imagen'],
                          width: 50,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.movie, color: Colors.white70),
                        ),
                      ),
                      title: Text(
                        peli['titulo'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${peli['genero']} • ${peli['anio']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () => mostrarInfo(context, peli),
                    ),
                  );
                }).toList(),

                const Divider(
                  thickness: 1,
                  color: Colors.white24,
                  indent: 16,
                  endIndent: 16,
                ),
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
      backgroundColor: Colors.grey.shade900,
      title: Text(
        pelicula['titulo'],
        style: const TextStyle(
            color: Colors.redAccent, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                pelicula['imagen'],
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.movie, size: 100, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 10),
            Text('Género: ${pelicula['genero']}',
                style: const TextStyle(color: Colors.white70)),
            Text('Año: ${pelicula['anio']}',
                style: const TextStyle(color: Colors.white70)),
            Text('Duración: ${pelicula['duracion']}',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Text(
              pelicula['descripcion'],
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text("Reproducir película"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => YoutubeTrailerScreen(url: pelicula['trailer'])),
            );
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cerrar',
            style: TextStyle(color: Colors.white70),
          ),
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
