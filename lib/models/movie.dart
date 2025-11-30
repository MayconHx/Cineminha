import 'package:hive/hive.dart';

class Movie {
  String title;
  String? genre;
  int? year;
  String? poster;
  bool watched;

  Movie({
    required this.title,
    this.genre,
    this.year,
    this.poster,
    this.watched = false,
  });
}

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 0;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Movie(
      title: fields[0] as String,
      genre: fields[1] as String?,
      year: fields[2] as int?,
      poster: fields[3] as String?,
      watched: fields[4] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.genre)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.poster)
      ..writeByte(4)
      ..write(obj.watched);
  }
}
