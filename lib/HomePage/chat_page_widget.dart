import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late SpeechToText _speech;
  bool _isListening = false;
  String _input = "abc";
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = SpeechToText();
  }

  _buildMessageComposer() {
    return Container(
      color: Colors.white,
      height: 100,
      child: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(hintText: 'Start typing or talking...'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: const Text(
          'Chat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
            iconSize: 30,
            color: Colors.white,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingActionButton(context),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: Colors.white),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 15),
                    itemCount: 10,
                    itemBuilder: (BuildContext context, int index) {
                      return Text('1');
                    }),
              ),
            ),
          ),
          _buildMessageComposer()
        ],
      ),
    );
  }

  AvatarGlow _buildFloatingActionButton(BuildContext context) {
    return AvatarGlow(
      glowColor: Theme.of(context).colorScheme.primary,
      animate: _isListening,
      endRadius: 75.0,
      duration: Duration(milliseconds: 2000),
      repeatPauseDuration: Duration(milliseconds: 200),
      child: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: _isListening
              ? Theme.of(context).colorScheme.primary
              : Colors.orange.shade200,
          elevation: 0.0,
          onPressed: () => _listen(),
          child: const Icon(
            Icons.mic,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  void _listen() async {
    setState(() => _isListening = !_isListening);
    return;
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
            onResult: (val) => setState(() {
                  _input = val.recognizedWords;
                  if (val.hasConfidenceRating && val.confidence > 0) {
                    _confidence = val.confidence;
                  }
                }));
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    }
  }
}
