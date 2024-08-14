import 'dart:async';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FavoritesDatabase {
  static final FavoritesDatabase instance = FavoritesDatabase._init();
  static Database? _database;

  FavoritesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favorites.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE favorites (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  songId TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  artist TEXT NOT NULL,
  uri TEXT NOT NULL
)
''');

    await db.execute('CREATE INDEX idx_songId ON favorites(songId)');
  }

  Future<void> addFavorite(SongModel song) async {
    final db = await instance.database;

    await db.insert(
      'favorites',
      {
        'songId': song.id.toString(),
        'title': song.displayNameWOExt,
        'artist': song.artist,
        'uri': song.uri,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFavorite(String songId) async {
    final db = await instance.database;

    await db.delete(
      'favorites',
      where: 'songId = ?',
      whereArgs: [songId],
    );
  }

  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    final db = await instance.database;

    return await db.query('favorites');
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
