import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:music/controller/speach.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final speechProvider = context.watch<SpeechProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        title: SizedBox(
          height: 45,
          child: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              suffixIcon: GestureDetector(
                onLongPress: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.transparent,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LottieBuilder.asset(
                              "assets/lotties/listening.json",
                            ),
                          ],
                        ),
                      );
                    },
                  );
                  print(speechProvider.isListening);

                  await speechProvider.initSpeech();
                  speechProvider.startListening();
                  print(speechProvider.isListening);
                },
                child: const Icon(CupertinoIcons.mic),
              ),
              fillColor: Colors.grey.withOpacity(.2),
              filled: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Icon(
                  CupertinoIcons.search,
                ),
              ),
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
              hintText: "Qurilmada qo'shiqlarni qidirish",
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Text(speechProvider.text),
      ),
    );
  }
}
