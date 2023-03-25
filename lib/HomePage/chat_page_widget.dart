import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voicegpt/Models/message_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late SpeechToText _speech;
  late TextEditingController _textEditingController;

  final List<bool> _speechOptions = <bool>[false, true];

  final List<Message> _messages = <Message>[
    Message(
      isUser: true,
      text: 'Tell me a good place to go in United States',
    ),
    Message(
        isUser: false,
        text: 'IDK, try asking the actual ChatGPT',
        state: MessageState.CanPlay),
    Message(
      isUser: true,
      text: 'No i want to ask you',
    ),
    Message(
        isUser: false,
        text: 'But i really dont know',
        state: MessageState.Speaking),
    Message(
      isUser: true,
      text: 'Fine',
    ),
    Message(
      isUser: true,
      text: 'Tell me a good place to go in uy yu yu asd asd',
    ),
    Message(
      isUser: false,
      text: 'IDK, try asking the actual ChatGPT',
      state: MessageState.Loading
    ),
    Message(
      isUser: true,
      text: 'No i want to ask you',
    ),
    Message(
      isUser: false,
      text: 'But i really dont know',
    ),
    Message(
      isUser: true,
      text: 'Fine',
    ),
  ];

  bool _isListening = false;
  bool _isTextFieldNotEmpty = false;

  String _input = "abc";
  String _hintText = "Hold to Talk";
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = SpeechToText();
    _textEditingController = TextEditingController();
    _textEditingController.addListener(() {
      final isTextFieldNotEmpty = _textEditingController.text.isNotEmpty;
      setState(() {
        _isTextFieldNotEmpty = isTextFieldNotEmpty;
      });
    });
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
                    itemCount: _messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Message message = _messages[index];
                      return message.isUser
                          ? _buildUserMessage(_messages[index])
                          : _buildAppMessage(_messages[index]);
                    }),
              ),
            ),
          ),
          _buildMessageComposer()
        ],
      ),
    );
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
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide.none),
                            hintText: 'Start typing or talking...',
                            fillColor: Colors.grey[150],
                            filled: true,
                          ),
                        ),
                      ),
                      _isTextFieldNotEmpty
                          ? IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.send_rounded,
                                color: Colors.orange,
                                size: 25,
                              ))
                          : const SizedBox.shrink()
                    ],
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
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

  Widget _buildAppMessage(Message m) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1), // changes position of shadow
                      ),
                    ]),
                child: Icon(
                  Icons.sentiment_satisfied,
                  color: Colors.orange,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 8, 10, 0),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.text,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: m.isUser ? Colors.white : Colors.black54,
                          fontSize: 16),
                    ),
                    Text(
                      m.time,
                      style: TextStyle(
                          color: m.isUser ? Colors.white : Colors.black54,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
                width: 30, height: 30, child: _buildCurrentVoiceGPTState(m)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(Message m) {
    return Align(
      alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: m.isUser
            ? EdgeInsets.fromLTRB(100, 8, 8, 0)
            : EdgeInsets.fromLTRB(8, 8, 100, 0),
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        decoration: BoxDecoration(
          color: m.isUser ? Colors.orangeAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              m.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              m.text,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: m.isUser ? Colors.white : Colors.black54,
                  fontSize: 16),
            ),
            Text(
              m.time,
              style: TextStyle(
                  color: m.isUser ? Colors.white : Colors.black54,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  _buildCurrentVoiceGPTState(Message m) {
    return Container(
        child: m.state == MessageState.Null
            ? null
            : m.state == MessageState.Loading
                ? LoadingAnimationWidget.twoRotatingArc(
                    size: 20, color: Colors.orange)
                : m.state == MessageState.Speaking
                    ? LoadingAnimationWidget.beat(
                        size: 20, color: Colors.orange)
                    : m.state == MessageState.CanPlay
                        ? const Icon(
                            Icons.play_circle_outline_rounded,
                            color: Colors.orange,
                          )
                        : null);
  }
}
