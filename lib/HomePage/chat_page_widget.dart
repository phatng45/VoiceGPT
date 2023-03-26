import 'package:avatar_glow/avatar_glow.dart';
import 'package:flag/flag.dart';
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
        text: 'IDK, try asking the actual ChatGPT ad  asd asd sadas  as',
        state: SystemMessageState.CanPlay),
    Message(
      isUser: true,
      text: 'No i want to ask you',
    ),
    Message(
        isUser: false,
        text: 'But i really dont know',
        state: SystemMessageState.Speaking),
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
        state: SystemMessageState.Loading),
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
  bool _darkMode = false;
  bool _autoTTS = false;

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
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.more_horiz),
              iconSize: 30,
              color: Colors.white,
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
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
                          : _buildSystemMessage(_messages[index]);
                    }),
              ),
            ),
          ),
          _buildMessageComposer()
        ],
      ),
      endDrawer: _buildEndDrawer2(context),
    );
  }

  ClipRRect _buildEndDrawer2(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
      child: Drawer(
          backgroundColor: Colors.orange.shade50,
          child: ListView(children: [
            SizedBox(
              height: 120,
              child: DrawerHeader(
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Settings',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 25),
                      )),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                  )),
            ),
            SwitchListTile(
              title: Text(
                'Dark mode',
              ),
              secondary: Icon(Icons.dark_mode_outlined),
              value: _darkMode,
              activeColor: Colors.orangeAccent,
              onChanged: (value) => setState(() {
                _darkMode = value;
              }),
            ),
            SwitchListTile(
              title: Text('Auto TTS'),
              secondary: Icon(Icons.speaker_notes_outlined),
              value: _autoTTS,
              activeColor: Colors.orangeAccent,
              onChanged: (value) => setState(() {
                _autoTTS = value;
              }),
            ),
            ListTile(
              title: Text('Languages'),
              leading: Icon(Icons.language),
              onTap: () {
                _buildLanguageBottomSheet(context);
              },
            ),
            Divider(
              color: Colors.black45,
              indent: 15,
              endIndent: 15,
            ),
            ListTile(
              textColor: Colors.redAccent,
              title: Text('Remove history'),
              leading: Icon(
                Icons.delete,
                color: Colors.redAccent,
              ),
            ),
          ])),
    );
  }

  Future<void> _buildLanguageBottomSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: const Text(
                  'Select Language',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Row(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {},
                        iconSize: 50,
                        icon: Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black38,
                                  offset: Offset(0, 1),
                                  blurRadius: 2.0,
                                ),
                              ]),
                          child: Flag.fromCode(
                            FlagsCode.US,
                            borderRadius: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text('English (US)')
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {},
                        iconSize: 50,
                        icon: Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black38,
                                  offset: Offset(0, 1),
                                  blurRadius: 2.0,
                                ),
                              ]),
                          child: Flag.fromCode(
                            FlagsCode.VN,
                            borderRadius: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text('Vietnamese (VN)')
                    ],
                  )
                ],
              ),
            ],
          ),
        );
      },
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
                              children: const [Text('Touch'), Text('Hold')],
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
    // setState(() => _isListening = !_isListening);
    // return;
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus $val'),
        onError: (val) => print('onError $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
            onResult: (val) => setState(() {
                  print('onResult $val');
                  _input = val.recognizedWords;
                  if (val.hasConfidenceRating && val.confidence > 0) {
                    _confidence = val.confidence;
                  }
                }));
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Widget _buildSystemMessage(Message m) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSystemChatIcon(),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 275),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
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
                  ),
                ),
                _buildCurrentVoiceGPTState(m),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _buildSystemChatIcon() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 0, 0),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ]),
      child: const Icon(
        Icons.sentiment_satisfied,
        color: Colors.orange,
      ),
    );
  }

  Widget _buildUserMessage(Message m) {
    return Align(
      alignment: Alignment.centerRight,
      child: Flexible(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300),
          child: Container(
            margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  m.text,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16),
                ),
                Text(
                  m.time,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildCurrentVoiceGPTState(Message m) {
    return Container(
        child: m.state == SystemMessageState.Null
            ? null
            : m.state == SystemMessageState.Loading
                ? Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: LoadingAnimationWidget.twoRotatingArc(
                        size: 20, color: Colors.green),
                  )
                : m.state == SystemMessageState.Speaking
                    ? LoadingAnimationWidget.beat(size: 20, color: Colors.red)
                    : m.state == SystemMessageState.CanPlay
                        ? const Icon(
                            Icons.play_circle_outline_rounded,
                            color: Colors.orange,
                          )
                        : null);
  }
}
