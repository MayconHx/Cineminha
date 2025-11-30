import 'package:flutter/material.dart';
import '../models/movie.dart';

class MoviesPage extends StatelessWidget {
  final List<Movie> filmes;
  final void Function(Movie movie) onEdit;
  final void Function(Movie movie) onDelete;
  final void Function(Movie movie) onToggleWatched;

  const MoviesPage({
    super.key,
    required this.filmes,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleWatched,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Meus Filmes')),
      body: filmes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.movie_creation_outlined, size: 64),
                    SizedBox(height: 12),
                    Text('Nenhum filme adicionado.', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Toque no botão + para adicionar um filme.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : ListView.separated(
              itemCount: filmes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final filme = filmes[index];
                return MovieTile(
                  movie: filme,
                  onEdit: () => onEdit(filme),
                  onDelete: () => onDelete(filme),
                  onToggleWatched: () => onToggleWatched(filme),
                );
              },
            ),
    );
  }
}

/// Componente separado para cada item da lista.

class MovieTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleWatched;

  const MovieTile({
    super.key,
    required this.movie,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleWatched,
  });

  @override
  Widget build(BuildContext context) {
    final poster = movie.poster;
    final genre = movie.genre ?? '—';
    final year = movie.year?.toString() ?? '—';

    return Container(
      padding: const EdgeInsets.all(12),
      height: 180,
      child: Row(
        children: [
          // Carrega imagem 
          poster != null
              ? Image.network(
                  poster,
                  width: 120,
                  height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 120,
                    height: 160,
                    color: Colors.grey[900],
                    child: const Icon(Icons.movie, size: 64),
                  ),
                )
              : Container(
                  width: 120,
                  height: 160,
                  color: Colors.grey[900],
                  child: const Icon(Icons.movie, size: 64),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(movie.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('$genre • $year'),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(movie.watched ? Icons.check_box : Icons.check_box_outline_blank),
                      onPressed: onToggleWatched,
                      tooltip: movie.watched ? 'Marcar como não assistido' : 'Marcar como assistido',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                      tooltip: 'Excluir',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
