import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:music/controller/music_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Gap(10),
            Center(
              child: Container(
                height: 5,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Consumer<MusicController>(
                builder: (context, musicController, child) {
                  return ListView.builder(
                    itemCount: musicController.songs.length,
                    itemBuilder: (context, index) {
                      final item = musicController.songs[index];
                      return SongListItem(
                        song: item,
                        index: index + 1,
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Theme.of(context).splashColor,
                  ),
                  child: const Center(
                    child: Text(
                      "Yopish",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return const BottomSheetWidget();
      },
    );
  }
}

class SongListItem extends StatefulWidget {
  final SongModel song;
  final int index;

  const SongListItem({required this.song, super.key, required this.index});

  @override
  State<SongListItem> createState() => _SongListItemState();
}

class _SongListItemState extends State<SongListItem> {
  @override
  Widget build(BuildContext context) {
    final musicController = context.read<MusicController>();
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          musicController.isPlaying &&
                  musicController.currentSong == widget.song
              ? Image.asset(
                  "assets/images/song1.gif",
                  height: 18,
                )
              : Text(
                  widget.index.toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 15),
                ),
          const Gap(15),
          QueryArtworkWidget(
            artworkWidth: 40,
            artworkHeight: 40,
            artworkFit: BoxFit.cover,
            artworkBorder: const BorderRadius.all(Radius.circular(5)),
            id: widget.song.id,
            type: ArtworkType.AUDIO,
            nullArtworkWidget: Container(
              width: 40,
              height: 40,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Image.asset(
                "assets/images/fon.png",
                fit: BoxFit.cover,
              ),
            ),
          )
        ],
      ),
      title: Text(
        widget.song.displayNameWOExt,
        maxLines: 1,
        style: TextStyle(
          color: musicController.currentSong == widget.song
              ? Colors.purpleAccent
              : Colors.grey,
          fontSize: 15,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Image.asset(
            "assets/icons/not.png",
            width: 10,
            height: 10,
          ),
          const Gap(5),
          Expanded(
            child: Text(
              widget.song.artist == "<unknown>"
                  ? "Noma'lum ijrochi"
                  : widget.song.artist!,
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
      onTap: () {
        if (musicController.isPlaying &&
            musicController.currentSong == widget.song) {
          musicController.audioPlayer.play();
        } else {
          musicController.setSong(widget.song);
        }
      },
    );
  }
}
