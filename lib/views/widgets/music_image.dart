import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music/controller/music_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class MusicImage extends StatelessWidget {
  const MusicImage({super.key});

  @override
  Widget build(BuildContext context) {
    final musicController = context.watch<MusicController>();

    return QueryArtworkWidget(
      artworkBorder: BorderRadius.zero,
      artworkFit: BoxFit.cover,
      id: musicController.currentSong?.id ?? 0,
      type: ArtworkType.AUDIO,
      nullArtworkWidget: Image.asset("assets/images/fon.png",fit: BoxFit.cover,),
    );
  }
}
