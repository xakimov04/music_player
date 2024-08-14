import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

enum PlaybackMode { repeat, repeatOne, shuffle }

class MusicController extends ChangeNotifier {
  final AudioPlayer audioPlayer = AudioPlayer();
  final OnAudioQuery audioQuery = OnAudioQuery();
  final _songsController = StreamController<List<SongModel>>.broadcast();
  final _currentSongController = StreamController<SongModel?>.broadcast();
  final _isPlayingController = StreamController<bool>.broadcast();
  int currentIndex = 0;
  List<SongModel> songs = [];
  SongModel? currentSong;
  bool isPlaying = false;
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<PlaybackMode> playbackMode =
      ValueNotifier<PlaybackMode>(PlaybackMode.repeat);
  Stream<List<SongModel>> get songsStream => _songsController.stream;
  Stream<SongModel?> get currentSongStream => _currentSongController.stream;
  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  MusicController() {
    _init();
    listenToSongCompletion();
  }

  Future<void> loadSongs() async {
    if (await Permission.storage.isGranted) {
      try {
        isLoading.value = true;
        List<SongModel> allSongs = await audioQuery.querySongs(
          sortType: SongSortType.TITLE,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );

        songs = allSongs.where((song) => song.duration! >= 60000).toList();
        _songsController.add(songs);
        isLoading.value = false;
      } catch (e) {
        if (kDebugMode) {
          print("Failed to load songs: $e");
        }
      }
    }
  }

  Future<void> _init() async {
    await _requestPermissions();
    await loadSongs();
  }

  Future<void> _requestPermissions() async {
    if (!await Permission.storage.request().isGranted) {
      await Permission.storage.request();
    }
  }

  void setSong(SongModel song) async {
    currentSong = song;
    _currentSongController.add(currentSong);
    await audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
    play();
    notifyListeners();
  }

  void play() {
    audioPlayer.play();
    isPlaying = true;
    _isPlayingController.add(isPlaying);
  }

  void pause() {
    audioPlayer.pause();
    isPlaying = false;
    _isPlayingController.add(isPlaying);
  }

  void togglePlayPause() {
    if (audioPlayer.playing) {
      pause();
    } else {
      play();
    }
  }

  void playNext() {
    if (currentSong == null || songs.isEmpty) return;

    int nextIndex;
    if (playbackMode.value == PlaybackMode.shuffle) {
      nextIndex = Random().nextInt(songs.length);
    } else {
      final currentIndex = songs.indexOf(currentSong!);
      nextIndex = (currentIndex + 1) % songs.length;
    }
    setSong(songs[nextIndex]);
  }

  void playPrevious() {
    if (currentSong == null || songs.isEmpty) return;
    int previousIndex;
    if (playbackMode.value == PlaybackMode.shuffle) {
      previousIndex = Random().nextInt(songs.length);
    } else {
      final currentIndex = songs.indexOf(currentSong!);
      previousIndex = (currentIndex - 1 + songs.length) % songs.length;
    }
    setSong(songs[previousIndex]);
  }

  void listenToSongCompletion() {
    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        if (playbackMode.value == PlaybackMode.repeatOne) {
          audioPlayer.seek(Duration.zero);
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
    super.dispose();
    _songsController.close();
    _currentSongController.close();
    _isPlayingController.close();
    audioPlayer.dispose();
  }

  
}
