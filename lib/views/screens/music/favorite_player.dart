import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:music/controller/favorites_controller.dart';
import 'package:music/controller/music_controller.dart';
import 'package:music/service/favorite_database.dart';
import 'package:music/views/widgets/music_image.dart';
import 'package:music/views/widgets/music_list_show.dart';
import 'package:music/views/widgets/text_up_lower.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class FavoritePlayer extends StatefulWidget {
  final SongModel songModel;

  const FavoritePlayer({super.key, required this.songModel});

  @override
  State<FavoritePlayer> createState() => _FavoritePlayerState();
}

class _FavoritePlayerState extends State<FavoritePlayer> {
  @override
  void initState() {
    super.initState();
    final favoritesProvider =
        Provider.of<FavoritesProvider>(context, listen: false);
    favoritesProvider.checkIfFavorite(widget.songModel);
  }

  @override
  Widget build(BuildContext context) {
    final musicController = context.watch<FavoritesProvider>();
    final music = context.read<MusicController>();
    if (music.isPlaying) {
      music.pause();
    }

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: QueryArtworkWidget(
            artworkFit: BoxFit.cover,
            artworkBorder: BorderRadius.zero,
            id: musicController.currentSong!.id,
            type: ArtworkType.AUDIO,
            nullArtworkWidget: Image.asset(
              "assets/images/fon.png",
              fit: BoxFit.cover,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey,
                    ),
                    child: QueryArtworkWidget(
                      artworkBorder: BorderRadius.zero,
                      artworkFit: BoxFit.cover,
                      id: musicController.currentSong!.id,
                      type: ArtworkType.AUDIO,
                      nullArtworkWidget: Image.asset(
                        "assets/images/fon.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Gap(MediaQuery.of(context).size.height / 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<FavoritesProvider?>(
                      builder: (context, musicController, child) {
                        final currentSong = musicController?.currentSong;
                        if (currentSong == null) {
                          return const SizedBox.shrink();
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      textUpLower(currentSong.displayNameWOExt),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      currentSong.artist == "<unknown>"
                                          ? "Noma'lum ijrochi"
                                          : currentSong.artist.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(15),
                            Consumer<FavoritesProvider>(
                                builder: (context, value, child) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: GestureDetector(
                                  onTap: () =>
                                      value.toggleFavorite(currentSong),
                                  child: Icon(
                                    value.isFavorite
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    size: 35,
                                    color: value.isFavorite
                                        ? Colors.yellow
                                        : Colors.white,
                                  ),
                                ),
                              );
                            })
                          ],
                        );
                      },
                    ),
                    Gap(20.h),
                    StreamBuilder<Duration>(
                      stream: musicController.audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        final currentDuration = snapshot.data ?? Duration.zero;
                        final totalDuration =
                            musicController.audioPlayer.duration ??
                                Duration.zero;
                        return Column(
                          children: [
                            Slider(
                              activeColor: Colors.white,
                              inactiveColor: Colors.grey,
                              value: currentDuration.inSeconds.toDouble(),
                              max: totalDuration.inSeconds.toDouble(),
                              onChanged: (value) {
                                musicController.audioPlayer
                                    .seek(Duration(seconds: value.toInt()));
                                musicController.listenToSongCompletion();
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(currentDuration),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                  Text(
                                    _formatDuration(totalDuration),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Gap(20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ValueListenableBuilder<PlaybackMode>(
                                  valueListenable: musicController.playbackMode,
                                  builder: (context, mode, child) {
                                    String iconName;
                                    switch (mode) {
                                      case PlaybackMode.repeat:
                                        iconName = "repeat";
                                        break;
                                      case PlaybackMode.repeatOne:
                                        iconName = "repeat_one";
                                        break;
                                      case PlaybackMode.shuffle:
                                        iconName = "shuffle";
                                        break;
                                    }
                                    return IconButton(
                                      onPressed: () {
                                        musicController.updateIconName();
                                      },
                                      icon: Image(
                                        fit: BoxFit.cover,
                                        width: 30,
                                        height: 30,
                                        color: Colors.white,
                                        image: AssetImage(
                                            "assets/icons/$iconName.png"),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_previous_rounded,
                                      color: Colors.white),
                                  iconSize: 40,
                                  onPressed: () {
                                    musicController.playPrevious();
                                  },
                                ),
                                IconButton(
                                  onPressed: () async {
                                    musicController.togglePlayPause();
                                  },
                                  icon: Container(
                                    width: 70,
                                    height: 70.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      musicController.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_next_rounded,
                                      color: Colors.white),
                                  iconSize: 40,
                                  onPressed: () {
                                    musicController.playNext();
                                  },
                                ),
                                IconButton(
                                  onPressed: () =>
                                      BottomSheetWidget.show(context),
                                  icon: const Image(
                                    fit: BoxFit.cover,
                                    width: 30,
                                    height: 30,
                                    color: Colors.white,
                                    image: AssetImage(
                                        "assets/icons/list_music.png"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Gap(20.h),
            ],
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(CupertinoIcons.ellipsis_vertical),
        ),
      ],
      leading: IconButton(
        icon: Transform.rotate(
          angle: -pi / 2,
          child:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
