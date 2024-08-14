import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/controller/music_controller.dart';
import 'package:music/service/favorite_database.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FavoritesProvider with ChangeNotifier {
  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;
  bool isPlaying = false;
  SongModel? currentSong;

  final StreamController<SongModel?> _currentSongController =
      StreamController.broadcast();
  final StreamController<bool> _isPlayingController =
      StreamController.broadcast();
  final StreamController<List<SongModel>> _songsController =
      StreamController.broadcast();

  List<SongModel> _favoriteSongs = [];
  List<SongModel> get favoriteSongs => _favoriteSongs;

  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer get audioPlayer => _audioPlayer;

  ValueNotifier<PlaybackMode> playbackMode = ValueNotifier(PlaybackMode.repeat);

  Stream<SongModel?> get currentSongStream => _currentSongController.stream;
  Stream<bool> get isPlayingStream => _isPlayingController.stream;
  Stream<List<SongModel>> get songsStream => _songsController.stream;

  FavoritesProvider() {
    _init();
    listenToSongCompletion();
  }

  Future<void> _init() async {
    await fetchFavoriteSongs();
  }

  Future<void> fetchFavoriteSongs() async {
    final favorites = await FavoritesDatabase.instance.fetchFavorites();
    final audioQuery = OnAudioQuery();
    final allSongs = await audioQuery.querySongs();

    _favoriteSongs = allSongs
        .where((song) =>
            favorites.any((fav) => fav['songId'] == song.id.toString()))
        .toList();
    _songsController.add(_favoriteSongs);
    notifyListeners();
  }

  Future<void> checkIfFavorite(SongModel songModel) async {
    final favorites = await FavoritesDatabase.instance.fetchFavorites();
    _isFavorite =
        favorites.any((fav) => fav['songId'] == songModel.id.toString());
    notifyListeners();
  }

  Future<void> toggleFavorite(SongModel songModel) async {
    if (_isFavorite) {
      await FavoritesDatabase.instance.removeFavorite(songModel.id.toString());
    } else {
      await FavoritesDatabase.instance.addFavorite(songModel);
    }
    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  Future<void> setSong(SongModel song) async {
    currentSong = song;
    _currentSongController.add(currentSong);
    await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
    play();
    notifyListeners();
  }

  void play() {
    _audioPlayer.play();
    isPlaying = true;
    _isPlayingController.add(isPlaying);
    notifyListeners();
  }

  void pause() {
    _audioPlayer.pause();
    isPlaying = false;
    _isPlayingController.add(isPlaying);
    notifyListeners();
  }

  void togglePlayPause() {
    if (_audioPlayer.playing) {
      pause();
    } else {
      play();
    }
  }

  void playNext() {
    if (currentSong == null || _favoriteSongs.isEmpty) return;

    int nextIndex;
    if (playbackMode.value == PlaybackMode.shuffle) {
      nextIndex = Random().nextInt(_favoriteSongs.length);
    } else {
      final currentIndex = _favoriteSongs.indexOf(currentSong!);
      nextIndex = (currentIndex + 1) % _favoriteSongs.length;
    }
    setSong(_favoriteSongs[nextIndex]);
  }

  void playPrevious() {
    if (currentSong == null || _favoriteSongs.isEmpty) return;

    int previousIndex;
    if (playbackMode.value == PlaybackMode.shuffle) {
      previousIndex = Random().nextInt(_favoriteSongs.length);
    } else {
      final currentIndex = _favoriteSongs.indexOf(currentSong!);
      previousIndex =
          (currentIndex - 1 + _favoriteSongs.length) % _favoriteSongs.length;
    }
    setSong(_favoriteSongs[previousIndex]);
  }

  void listenToSongCompletion() {
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        if (playbackMode.value == PlaybackMode.repeatOne) {
          _audioPlayer.seek(Duration.zero);
          play();
        } else {
          playNext();
        }
      }
    });
  }

  void updateIconName() {
    if (playbackMode.value == PlaybackMode.repeat) {
      playbackMode.value = PlaybackMode.repeatOne;
    } else if (playbackMode.value == PlaybackMode.repeatOne) {
      playbackMode.value = PlaybackMode.shuffle;
    } else if (playbackMode.value == PlaybackMode.shuffle) {
      playbackMode.value = PlaybackMode.repeat;
    }
  }

  @override
  void dispose() {
    _currentSongController.close();
    _isPlayingController.close();
    _songsController.close();
    _audioPlayer.dispose();
    super.dispose();
  }

}
