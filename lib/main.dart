import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music/controller/favorites_controller.dart';
import 'package:music/controller/music_controller.dart';
import 'package:music/controller/speach.dart';
import 'package:music/views/screens/music/music_list.dart';
import 'package:provider/provider.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MusicController()),
        ChangeNotifierProvider(create: (context) => SpeechProvider()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
      ],
      builder: (context, child) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          child: MaterialApp(
            theme: ThemeData.dark().copyWith(
                scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47)),
            debugShowCheckedModeBanner: false,
            home: const MusicList(),
          ),
        );
      },
    );
  }
}
