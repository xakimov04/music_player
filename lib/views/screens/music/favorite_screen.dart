import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:music/controller/favorites_controller.dart';
import 'package:music/views/screens/music/favorite_player.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isSortedByName = true;
  @override
  void initState() {
    context.read<FavoritesProvider>().fetchFavoriteSongs();
    super.initState();
  }

  void _sortSongs(FavoritesProvider provider) {
    if (_isSortedByName) {
      provider.favoriteSongs
          .sort((a, b) => a.displayNameWOExt.compareTo(b.displayNameWOExt));
    } else {
      provider.favoriteSongs.sort(
          (a, b) => (a.artist ?? 'Unknown').compareTo(b.artist ?? 'Unknown'));
    }
  }

  Future<void> _refreshFavorites(FavoritesProvider provider) async {
    await provider.fetchFavoriteSongs();
    _sortSongs(provider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        centerTitle: true,
        title: const Text(
          'Favorite Songs',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_isSortedByName ? Icons.sort_by_alpha : Icons.sort,
                color: Colors.white),
            onPressed: () {
              setState(() {
                _isSortedByName = !_isSortedByName;
              });
              _sortSongs(context.read<FavoritesProvider>());
            },
          ),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          _sortSongs(provider);
          if (provider.favoriteSongs.isEmpty) {
            return Center(
              child: LottieBuilder.asset("assets/lotties/nott.json"),
            );
          }
          return RefreshIndicator(
            onRefresh: () => _refreshFavorites(provider),
            child: ListView.builder(
              itemCount: provider.favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = provider.favoriteSongs[index];
                return ListTile(
                  leading: QueryArtworkWidget(
                    artworkHeight: 40,
                    artworkWidth: 40,
                    artworkFit: BoxFit.cover,
                    artworkBorder: BorderRadius.circular(10),
                    id: song.id,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(CupertinoIcons.music_note_2),
                    ),
                  ),
                  title: Text(
                    song.displayNameWOExt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: provider.currentSong == song
                          ? Colors.purple
                          : Colors.white,
                      fontSize: 15,
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
                          song.artist == "<unknown>"
                              ? "Noma'lum ijrochi"
                              : song.artist ?? "Noma'lum ijrochi",
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
                  trailing: IconButton(
                    icon: const Icon(CupertinoIcons.ellipsis_vertical),
                    onPressed: () => provider.toggleFavorite(song),
                  ),
                  onTap: () {
                    if (provider.isPlaying && provider.currentSong == song) {
                      provider.audioPlayer.play();
                    } else {
                      provider.setSong(song);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoritePlayer(songModel: song),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
