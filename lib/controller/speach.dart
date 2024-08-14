import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isListening = false;
  String _text = '';

  String get text => _text;

  Future<void> initSpeech() async {
    bool available = await _speech.initialize();
    if (available) {
      notifyListeners();
    }
  }

  void startListening() {
    _speech.listen(onResult: (val) {
      _text = val.recognizedWords;
      isListening = val.finalResult;
      notifyListeners();
    });
  }

  void stopListening() {
    _speech.stop();
    isListening = false;
    notifyListeners();
  }
}
