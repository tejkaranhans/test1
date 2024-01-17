import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SpeechToTextPage(),
    );
  }
}

class SpeechToTextPage extends StatefulWidget {
  const SpeechToTextPage({Key? key}) : super(key: key);

  @override
  _SpeechToTextPage createState() => _SpeechToTextPage();
}

class _SpeechToTextPage extends State<SpeechToTextPage> {
  final microphonePermission = Permission.microphone;
  final TextEditingController _textController = TextEditingController();

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = "";

  // void listenForPermissions() async {
  //   final status = await Permission.microphone.status;
  //   print(status);
  //   switch (status) {
  //     case PermissionStatus.denied:
  //       requestForPermission();
  //       break;
  //     case PermissionStatus.granted:
  //       break;
  //     case PermissionStatus.limited:
  //       break;
  //     case PermissionStatus.permanentlyDenied:
  //       break;
  //     case PermissionStatus.restricted:
  //       break;
  //     case PermissionStatus.provisional:
  //       // TODO: Handle this case.
  //   }
  // }
  //
  // Future<void> requestForPermission() async {
  //   await Permission.microphone.request();
  // }
  //
  // Future<bool> checkPermissionStatus() async {
  //   final permission = Permission.microphone;
  //
  //   return await permission.status.isGranted;
  // }


  @override
  void initState() {
    super.initState();
    // listenForPermissions();
    if (!_speechEnabled) {
      _initSpeech();
    }
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    _lastWords = "";
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      localeId: "en_En",
      cancelOnError: false,
      partialResults: false,
      listenMode: ListenMode.confirmation,
    );
    print("Start Listening");
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    print("Stop Listening");

    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = "$_lastWords${result.recognizedWords} ";
      _textController.text = _lastWords;
      print("You said: "+_lastWords);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(12),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 6,
                      maxLines: 10,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  FloatingActionButton.small(
                    onPressed:() async {
                      // final status = await microphonePermission.request();
                      // If not yet listening for speech start, otherwise stop
                      // if (status.isGranted) {
                      _speechToText.isNotListening
                          ? _startListening()
                          : _stopListening();
                      // }
                    },
                    tooltip: 'Listen',
                    backgroundColor: Colors.blueGrey,
                    child: Icon(_speechToText.isNotListening
                        ? Icons.mic_off
                        : Icons.mic),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}