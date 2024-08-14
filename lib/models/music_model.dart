class Music {
  int? id;
  String title;
  String artist;
  bool isFavorite;

  Music(
      {this.id,
      required this.title,
      required this.artist,
      this.isFavorite = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Music.fromMap(Map<String, dynamic> map) {
    return Music(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      isFavorite: map['isFavorite'] == 1,
    );
  }
}
