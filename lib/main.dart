import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/movie.dart';
import 'tmdb_service.dart';
import 'screens/home_page.dart';
import 'screens/movies_page.dart';
import 'screens/credits_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MovieAdapter());
  await Hive.openBox<Movie>('movies');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cineminha',
      theme: ThemeData.dark(),
      home: const Cineminha(),
    );
  }
}

class Cineminha extends StatefulWidget {
  const Cineminha({super.key});

  @override
  State<Cineminha> createState() => _CineminhaState();
}

class _CineminhaState extends State<Cineminha> {
  final TmdbService tmdb = TmdbService();
  int _currentIndex = 0;
  List<Movie> filmes = [];
  late final Box<Movie> _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<Movie>('movies');
    filmes = _box.values.toList().reversed.toList();
  }

  Future<void> _addMovie(Movie movie) async {
    await _box.add(movie);
    setState(() {
      filmes.insert(0, movie);
    });
  }

  Future<void> _editMovie(int index, Movie movie) async {
    final realIndex = _box.length - 1 - index;
    await _box.putAt(realIndex, movie);
    setState(() {
      filmes[index] = movie;
    });
  }

  void _deleteMovie(int index) {
    final realIndex = _box.length - 1 - index;
    _box.deleteAt(realIndex);
    setState(() {
      filmes.removeAt(index);
    });
  }

  void _toggleWatched(int index) {
    final item = filmes[index];
    final updated = Movie(
      title: item.title,
      genre: item.genre,
      year: item.year,
      poster: item.poster,
      watched: !item.watched,
    );
    _editMovie(index, updated);
  }

  void _openAddModal(BuildContext context, {Movie? movie, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
        builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: AddEditMovieModal(
            tmdb: tmdb,
            movie: movie,
            onSave: (m) async {
              if (index == null) {
                await _addMovie(m);
              } else {
                await _editMovie(index, m);
              }
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onOpenMovies: () => setState(() => _currentIndex = 1)),
      MoviesPage(
        filmes: filmes,
        // Agora os callbacks recebem o `Movie` em vez do índice.
        onEdit: (movie) {
          final i = filmes.indexOf(movie);
          if (i != -1) _openAddModal(context, movie: movie, index: i);
        },
        onDelete: (movie) {
          final i = filmes.indexOf(movie);
          if (i != -1) _deleteMovie(i);
        },
        onToggleWatched: (movie) {
          final i = filmes.indexOf(movie);
          if (i != -1) _toggleWatched(i);
        },
      ),
      const CreditsPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Filmes'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Créditos'),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => _openAddModal(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class AddEditMovieModal extends StatefulWidget {
  final TmdbService tmdb;
  final Movie? movie;
  final Future<void> Function(Movie movie) onSave;

  const AddEditMovieModal({super.key, required this.tmdb, this.movie, required this.onSave});

  @override
  State<AddEditMovieModal> createState() => _AddEditMovieModalState();
}

class _AddEditMovieModalState extends State<AddEditMovieModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _genreController;
  late final TextEditingController _yearController;
  late final TextEditingController _posterController;
  final _queryController = TextEditingController();
  List _searchResults = [];
  bool _loading = false;
  bool _watched = false;

  @override
  void initState() {
    super.initState();
    final m = widget.movie;
    _titleController = TextEditingController(text: m?.title ?? '');
    _genreController = TextEditingController(text: m?.genre ?? '');
    _yearController = TextEditingController(text: m?.year?.toString() ?? '');
    _posterController = TextEditingController(text: m?.poster ?? '');
    _watched = m?.watched ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    _posterController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _searchByName() async {
    final q = _queryController.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _searchResults = [];
    });
    final results = await widget.tmdb.searchMovies(q, limit: 5);
    setState(() {
      _loading = false;
      _searchResults = results;
    });
  }

  Future<void> _saveManual() async {
    final movie = Movie(
      title: _titleController.text.trim(),
      genre: _genreController.text.trim().isEmpty ? null : _genreController.text.trim(),
      year: int.tryParse(_yearController.text.trim()),
      poster: _posterController.text.trim().isEmpty ? null : _posterController.text.trim(),
      watched: _watched,
    );
    await widget.onSave(movie);
  }

  Movie _mapTmdbToMovie(Map<String, dynamic> item) {
    final poster = item['poster_path'] != null ? 'https://image.tmdb.org/t/p/w500${item['poster_path']}' : null;
    final release = item['release_date'] as String?;
    final year = (release != null && release.isNotEmpty) ? int.tryParse(release.split('-')[0]) : null;
    return Movie(
      title: item['title'] ?? item['name'] ?? 'Sem título',
      genre: 'Desconhecido',
      year: year,
      poster: poster,
      watched: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.movie != null;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEditing ? 'Editar Filme' : 'Adicionar Filme', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Título')),
                  TextFormField(controller: _genreController, decoration: const InputDecoration(labelText: 'Gênero')),
                  TextFormField(controller: _yearController, decoration: const InputDecoration(labelText: 'Ano'), keyboardType: TextInputType.number),
                  TextFormField(controller: _posterController, decoration: const InputDecoration(labelText: 'URL do Poster (opcional)')),
                  SwitchListTile(value: _watched, onChanged: (v) => setState(() => _watched = v), title: const Text('Assistido')),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveManual,
                          child: Text(isEditing ? 'Salvar' : 'Adicionar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            const Text('Ou buscar por nome', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _queryController, decoration: const InputDecoration(labelText: 'Nome do filme')),
            const SizedBox(height: 8),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _searchByName, child: const Text('Buscar por nome')),
            const SizedBox(height: 8),
            if (_searchResults.isNotEmpty)
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final item = _searchResults[index] as Map<String, dynamic>;
                    final title = item['title'] ?? item['name'] ?? 'Sem título';
                    final poster = item['poster_path'] != null ? 'https://image.tmdb.org/t/p/w500${item['poster_path']}' : null;
                    final vote = item['vote_average'] ?? '-';
                    return ListTile(
                      leading: poster != null ? Image.network(poster, width: 50, fit: BoxFit.cover) : const Icon(Icons.movie),
                      title: Text(title),
                      subtitle: Text('⭐ $vote'),
                      onTap: () async {
                        final mapped = _mapTmdbToMovie(item);
                        await widget.onSave(mapped);
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
