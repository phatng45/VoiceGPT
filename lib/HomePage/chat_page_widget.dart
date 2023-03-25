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
  final List<bool> _speechOptions = <bool>[false, true];

  bool _isListening = false;
  String _input = "abc";
  String _hintText = "Hold to Talk";
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = SpeechToText();
  }

  _buildMessageComposer() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(
            indent: 20,
            endIndent: 20,
            thickness: 1,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none),
                        hintText: 'Start typing or talking...',
                        fillColor: Colors.grey[150],
                        filled: true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 135),
                  child: Center(
                      child: Text(
                    _hintText,
                    style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontStyle: FontStyle.italic),
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Expanded(flex: 1, child: _buildMicButton()),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10, top: 55),
                          child: Container(
                            padding: EdgeInsets.zero,
                            height: 40,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10))),
                            child: ToggleButtons(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              selectedBorderColor: Colors.orange[700],
                              selectedColor: Colors.white,
                              // disabledColor: Colors.white,
                              // color
                              fillColor: Colors.orange.shade200,
                              color: Colors.orange[400],
                              constraints: const BoxConstraints(
                                minHeight: 40.0,
                                minWidth: 62.0,
                              ),
                              isSelected: _speechOptions,
                              children: const [Text('Manual'), Text('Auto')],
                              onPressed: (int index) {
                                setState(() {
                                  for (int i = 0;
                                      i < _speechOptions.length;
                                      i++) {
                                    _speechOptions[i] = i == index;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
                // SizedBox(height: 50,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AvatarGlow _buildMicButton() {
    return AvatarGlow(
      glowColor: Theme.of(context).colorScheme.primary,
      animate: _isListening,
      endRadius: 75.0,
      curve: Curves.easeInOut,
      child: RawMaterialButton(
        onPressed: () => _listen(),
        elevation: 0.0,
        fillColor: _isListening
            ? Theme.of(context).colorScheme.primary
            : Colors.orange.shade200,
        child: Icon(
          Icons.mic,
          size: 30.0,
          color: Colors.white,
        ),
        padding: EdgeInsets.fromLTRB(15, 18, 15, 15),
        shape: CircleBorder(),
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
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: _buildFloatingActionButton(context),
      // bottomNavigationBar:  BottomAppBar(
      //   height: 80,
      //   shape: CircularNotchedRectangle(),
      //   // color: Colors.blue,
      //   // surfaceTintColor: Colors.blue,
      // ),
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
      curve: Curves.easeInOut,
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
