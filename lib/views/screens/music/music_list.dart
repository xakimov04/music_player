import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:get/utils.dart';
import 'package:music/controller/music_controller.dart';
import 'package:music/views/screens/music/favorite_screen.dart';
import 'package:music/views/screens/music/music_player.dart';
import 'package:music/views/screens/search/search_screen.dart';
import 'package:music/views/widgets/custom_page.dart';
import 'package:music/views/widgets/text_up_lower.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key});

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  Widget slider = SleekCircularSlider(
    appearance: CircularSliderAppearance(
      size: 30,
      startAngle: 0,
      angleRange: 360,
      customWidths: CustomSliderWidths(
        progressBarWidth: 2,
      ),
    ),
  );
  @override
  void initState() {
    context.read<MusicController>().loadSongs();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final musicController = context.watch<MusicController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: GestureDetector(
            onTap: () {},
            child: const Icon(
              Icons.menu,
              size: 25,
            ),
          ),
        ),
        title: SizedBox(
          height: 45,
          child: TextField(
            readOnly: true,
            onTap: () {
              Navigator.push(
                context,
                CustomPageRoute(x: 1, y: 0, child: const SearchScreen()),
              );
            },
            decoration: InputDecoration(
              suffixIcon: const Icon(CupertinoIcons.mic),
              fillColor: Colors.grey.withOpacity(.2),
              filled: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 5, top: 5),
                child: Icon(
                  CupertinoIcons.search,
                ),
              ),
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
              hintText: "Qo'shiqlar, pleylistlar va ijrochilarni qidiring",
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 70,
        child: Stack(
          children: [
            if (musicController.currentSong != null)
              Container(
                clipBehavior: Clip.hardEdge,
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
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
            StreamBuilder<bool>(
              stream: musicController.isPlayingStream,
              builder: (context, isPlayingSnapshot) {
                final isPlaying = isPlayingSnapshot.data ?? false;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.45),
                            Colors.black.withOpacity(0.65),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            if (musicController.currentSong != null)
                              CircleAvatar(
                                child: QueryArtworkWidget(
                                  artworkWidth: double.infinity,
                                  artworkHeight: double.infinity,
                                  id: musicController.currentSong?.id ?? 1,
                                  type: ArtworkType.AUDIO,
                                  nullArtworkWidget: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      "assets/images/fon.png",
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            const Gap(5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    musicController
                                            .currentSong?.displayNameWOExt ??
                                        "",
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    musicController.currentSong?.artist
                                            .toString() ??
                                        "",
                                    maxLines: 1,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Gap(10),
                            GestureDetector(
                              onTap: () {
                                musicController.togglePlayPause();
                              },
                              child: Stack(
                                children: [
                                  StreamBuilder<Duration>(
                                    stream: musicController
                                        .audioPlayer.positionStream,
                                    builder: (context, snapshot) {
                                      final currentDuration = snapshot.data ??
                                          const Duration(seconds: 0);
                                      final totalDuration = musicController
                                              .audioPlayer.duration ??
                                          const Duration(seconds: 0);
                                      return SleekCircularSlider(
                                        appearance: CircularSliderAppearance(
                                          size: 32,
                                          startAngle: 0,
                                          angleRange: 360,
                                          customWidths: CustomSliderWidths(
                                            progressBarWidth: 2,
                                          ),
                                        ),
                                        max: totalDuration.inSeconds.toDouble(),
                                        onChange: (value) {
                                          musicController.audioPlayer.seek(
                                              Duration(seconds: value.toInt()));
                                          musicController
                                              .listenToSongCompletion();
                                        },
                                        initialValue: currentDuration.inSeconds
                                            .toDouble(),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Icon(
                                      size: 32,
                                      isPlaying
                                          ? Icons.pause_circle
                                          : Icons.play_circle_sharp,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(10),
                            GestureDetector(
                              onTap: () {
                                musicController.playNext();
                              },
                              child: const Icon(Icons.skip_next_rounded),
                            ),
                            const Gap(5),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: _HeaderButtons(),
                ),
              ),
              SliverToBoxAdapter(
                child: StreamBuilder<List<SongModel>>(
                  stream: musicController.songsStream,
                  builder: (context, snapshot) {
                    if (musicController.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 3),
                        child: const Center(
                          child: Text(
                            'Musiqa topilmadi',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      );
                    }

                    final songs = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final music = songs[index];

                        return StreamBuilder<SongModel?>(
                          stream: musicController.currentSongStream,
                          builder: (context, currentSongSnapshot) {
                            final currentSong = currentSongSnapshot.data;
                            return StreamBuilder<bool>(
                              stream: musicController.isPlayingStream,
                              builder: (context, isPlayingSnapshot) {
                                final isPlaying =
                                    isPlayingSnapshot.data ?? false;

                                return ListTile(
                                  onTap: () {
                                    if (isPlaying && currentSong == music) {
                                      musicController.audioPlayer.play();
                                    } else {
                                      musicController.setSong(music);
                                    }
                                    Navigator.push(
                                      context,
                                      CustomPageRoute(
                                        x: 0,
                                        y: 1,
                                        child: MusicPlayer(songModel: music),
                                      ),
                                    );
                                  },
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isPlaying && currentSong == music)
                                        GestureDetector(
                                          onTap: () =>
                                              musicController.togglePlayPause(),
                                          child: Image.asset(
                                            "assets/images/song1.gif",
                                            height: 25,
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {},
                                        child: const Icon(
                                          CupertinoIcons.ellipsis_vertical,
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    textUpLower(music.displayNameWOExt),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: currentSong == music
                                          ? Colors.purple
                                          : Colors.white,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Image.asset(
                                        "assets/icons/not.png",
                                        width: 12,
                                        height: 12,
                                      ),
                                      const Gap(5),
                                      Expanded(
                                        child: Text(
                                          music.artist == "<unknown>"
                                              ? "Noma'lum ijrochi"
                                              : music.artist!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  leading: QueryArtworkWidget(
                                    artworkHeight: 40,
                                    artworkWidth: 40,
                                    artworkFit: BoxFit.cover,
                                    artworkBorder: BorderRadius.circular(10),
                                    id: music.id,
                                    type: ArtworkType.AUDIO,
                                    nullArtworkWidget: Container(
                                      width: 40,
                                      height: 40,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Image.asset(
                                        "assets/images/fon.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderButtons extends StatelessWidget {
  const _HeaderButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Gap(15),
        Expanded(
          child: _GradientButton(
            colors: [Colors.purple.shade900, Colors.purple.shade500],
            icon: Icons.star_rate_rounded,
            text: "Saralanganlar",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesPage(),
                ),
              );
            },
          ),
        ),
        const Gap(10),
        Expanded(
          child: _GradientButton(
            onTap: () {},
            colors: [Colors.green.shade900, Colors.green.shade300],
            icon: Icons.music_note,
            text: "Pleylistlar",
          ),
        ),
        const Gap(10),
        Expanded(
          child: _GradientButton(
            onTap: () {},
            colors: [Colors.amber.shade900, Colors.amber.shade300],
            icon: Icons.access_time_filled_sharp,
            text: "Eng so'nggi",
          ),
        ),
        const Gap(15),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final List<Color> colors;
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _GradientButton({
    required this.colors,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 25,
              ),
              Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
