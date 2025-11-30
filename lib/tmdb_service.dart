import 'dart:convert';
import 'package:http/http.dart' as http;

class TmdbService {
  final String apiKey = "90be6e6cf77c9f0435f78676dfb01afc";

  Future<Map<String, dynamic>?> getMovieById(String id) async {
    if (id.isEmpty) return null;
    final url =
        "https://api.themoviedb.org/3/movie/$id?api_key=$apiKey&language=pt-BR";

    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) return null;
    final json = jsonDecode(res.body);
    if (json is Map<String, dynamic>) return json;
    return null;
  }

  Future<List> searchMovies(String query, {int limit = 5}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final encoded = Uri.encodeQueryComponent(q);
    final url =
        "https://api.themoviedb.org/3/search/movie?api_key=$apiKey&language=pt-BR&query=$encoded&page=1";

    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) return [];
    final json = jsonDecode(res.body);
    final results = json["results"];
    if (results is List) return results.take(limit).toList();
    return [];
  }
}
