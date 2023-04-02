import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voicegpt/Models/message_model.dart';
import 'package:voicegpt/api_key.dart';
import 'package:voicegpt/main.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final ScrollController _scrollController = ScrollController();
  final DateFormat timeFormat = DateFormat("HH:mm");
  late TextEditingController _textEditingController;

  final List<bool> _speechOptions = <bool>[false, true];
  late List<Message> _messages = <Message>[];

  static const String MESSAGES_PREF_KEY = 'messages_key';
  static const String DARK_MODE_PREF_KEY = 'dark_mode_key';
  static const String AUTO_TTS_PREF_KEY = 'auto_tts_key';
  static const String LANGUAGE_PREF_KEY = 'language_key';
  static const String TOUCH_TO_SPEAK_PREF_KEY = 'touch_key';

  final openAI = OpenAI.instance.build(
      token: OPEN_AI_API_KEY,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 100)),
      isLog: false);

  bool _isListening = false;
  bool _isTextFieldNotEmpty = false;
  bool _darkMode = false;
  bool _autoTTS = true;

  late String _hintText = 'holdToTalk'.tr;

  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController();
    _textEditingController.addListener(() {
      final isTextFieldNotEmpty = _textEditingController.text.isNotEmpty;
      setState(() {
        _isTextFieldNotEmpty = isTextFieldNotEmpty;
      });
    });

    _loadSettings();
    _loadMessages().then((value) => {
          setState(() {
            _messages = value;
          })
        });
    _updateHintText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: Text(
          'chat'.tr,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0.0,
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              IconButton(
                splashColor: Colors.orangeAccent,
                onPressed: () => _buildLanguageBottomSheet(context),
                iconSize: 10,
                icon: Flag.fromCode(
                  FlagsCode.US,
                  width: 25,
                  height: 25,
                  borderRadius: 20,
                  fit: BoxFit.cover,
                ),
              ),
              const Text(
                'EN',
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.more_horiz),
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
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: _darkMode ? Colors.grey[900] : Colors.white),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                child: ListView.builder(
                    padding: const EdgeInsets.only(top: 15),
                    itemCount: _messages.length,
                    controller: _scrollController,
                    itemBuilder: (BuildContext context, int index) {
                      final Message message = _messages[index];
                      return message.isUser()
                          ? _buildUserMessage(_messages[index])
                          : _buildSystemMessage(_messages[index]);
                    }),
              ),
            ),
          ),
          _buildMessageComposer()
        ],
      ),
      endDrawer: _buildEndDrawer(context),
    );
  }

  ClipRRect _buildEndDrawer(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
      child: Drawer(
          backgroundColor: _darkMode ? Colors.grey[900] : Colors.orange.shade50,
          child: ListView(children: [
            SizedBox(
              height: 120,
              child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                  ),
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'settings'.tr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 25),
                      ))),
            ),
            SwitchListTile(
              title: Text(
                'darkMode'.tr,
              ),
              secondary: Icon(Icons.dark_mode_outlined),
              value: _darkMode,
              activeColor: Colors.orangeAccent,
              onChanged: (value) => setState(() {
                _darkMode = value;
                Get.changeTheme(_darkMode ? MyApp.darkTheme : MyApp.lightTheme);
                _saveSettings();
              }),
            ),
            SwitchListTile(
              title: Text('autoTTS'.tr),
              secondary: const Icon(Icons.speaker_notes_outlined),
              value: _autoTTS,
              activeColor: Colors.orangeAccent,
              onChanged: (value) => setState(() {
                _autoTTS = value;
                _saveSettings();
              }),
            ),
            ListTile(
              title: Text('languages'.tr),
              leading: const Icon(Icons.language),
              onTap: () {
                _buildLanguageBottomSheet(context);
              },
            ),
            const Divider(
              color: Colors.black45,
              indent: 15,
              endIndent: 15,
            ),
            ListTile(
              textColor: Colors.redAccent,
              title: Text('removeHistory'.tr),
              leading: const Icon(
                Icons.delete,
                color: Colors.redAccent,
              ),
              onTap: () {
                _buildConfirmRemoveHistoryDialog(context);
              },
            ),
          ])),
    );
  }

  Future<void> _buildLanguageBottomSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: _darkMode ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
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
                child: Text(
                  'Select Language'.tr,
                  style: const TextStyle(fontSize: 25),
                ),
              ),
              Row(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          Get.updateLocale(const Locale('en', 'US'));
                          Navigator.pop(context);
                          _updateHintText();
                          _saveSettings();
                        },
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
                      const Text('English (US)')
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          Get.updateLocale(const Locale('vi', 'VN'));
                          Navigator.pop(context);
                          _updateHintText();
                          _saveSettings();
                        },
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
                      const Text('Tiếng Việt (VN)')
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
      color: _darkMode ? Colors.grey[900] : Colors.white,
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
                            hintText: 'Start typing or talking...'.tr,
                            fillColor: Colors.grey[150],
                            filled: true,
                          ),
                        ),
                      ),
                      _isTextFieldNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _send(_textEditingController.text);
                              },
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: ToggleButtons(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              selectedBorderColor: Colors.orange[700],
                              selectedColor: Colors.white,
                              borderColor: Colors.orange,
                              fillColor: Colors.orange.shade200,
                              color: Colors.orange[400],
                              constraints: const BoxConstraints(
                                minHeight: 40.0,
                                minWidth: 55.0,
                              ),
                              isSelected: _speechOptions,
                              children: [Text('Touch'.tr), Text('Hold'.tr)],
                              onPressed: (int index) {
                                setState(() {
                                  for (int i = 0;
                                      i < _speechOptions.length;
                                      i++) {
                                    _speechOptions[i] = i == index;
                                  }
                                  _saveSettings();
                                  _updateHintText();
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

  bool isInHoldMode() => _speechOptions[1] == true;

  AvatarGlow _buildMicButton() {
    return AvatarGlow(
      glowColor: Theme.of(context).colorScheme.primary,
      animate: _isListening,
      endRadius: 75.0,
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTapDown: (tap) {
          if (!_isListening) {
            _listen();
          } else if (!isInHoldMode()) {
            _stt.stop();
            setState(() {
              _isListening = false;
            });
          }

          _updateHintText();
        },
        onTapCancel: () {
          if (isInHoldMode()) {
            _stt.stop();
            setState(() {
              _isListening = false;
            });
          }

          _updateHintText();
        },
        child: RawMaterialButton(
          onPressed: () {
            _updateHintText();
          },
          elevation: 0.0,
          fillColor: _isListening
              ? Theme.of(context).colorScheme.primary
              : Colors.orange.shade200,
          padding: const EdgeInsets.fromLTRB(15, 18, 15, 15),
          shape: const CircleBorder(),
          child: const Icon(
            Icons.mic,
            size: 30.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _updateHintText() {
    setState(() {
      if (_isListening) {
        if (_speechOptions[0] == true) {
          _hintText = "Touch to Stop".tr;
        } else {
          _hintText = "Release to Stop".tr;
        }
      } else {
        if (_speechOptions[0] == true) {
          _hintText = "Touch to Talk".tr;
        } else {
          _hintText = "Hold to Talk".tr;
        }
      }
    });
  }

  void _listen() async {
    bool available = await _stt.initialize(onError: (val) {
      setState(() {
        _isListening = false;
        _updateHintText();
      });
    });
    if (available) {
      setState(() {
        _isListening = true;
        _updateHintText();
      });
      _stt.listen(
          listenMode: ListenMode.search,
          onResult: (val) => setState(() {
                _textEditingController.text = val.recognizedWords;
                _updateHintText();
              }));
    } else {
      setState(() => _isListening = false);
      _stt.stop();
      _updateHintText();
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
                    constraints: const BoxConstraints(maxWidth: 275),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(8, 11, 8, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: _darkMode ? Colors.grey[800] : Colors.grey[200],
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
                                color:
                                    _darkMode ? Colors.white : Colors.black54,
                                fontSize: 16),
                          ),
                          Text(
                            m.time,
                            style: TextStyle(
                                color:
                                    _darkMode ? Colors.white : Colors.black54,
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
          color: _darkMode ? Colors.grey[800] : Colors.white,
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
          constraints: const BoxConstraints(maxWidth: 300),
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 11, 8, 0),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16),
                ),
                Text(
                  m.time,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
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
        child: m.state == BotMessageState.Null
            ? null
            : m.state == BotMessageState.Loading
                ? Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: LoadingAnimationWidget.twoRotatingArc(
                        size: 20, color: Colors.green),
                  )
                : m.state == BotMessageState.Speaking
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _tts.stop();
                              m.state = BotMessageState.CanPlay;
                            });
                          },
                          icon: LoadingAnimationWidget.beat(
                              size: 20, color: Colors.red),
                        ),
                      )
                    : m.state == BotMessageState.CanPlay
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                for (Message message in _messages) {
                                  message.state = BotMessageState.CanPlay;
                                }

                                m.state = BotMessageState.Speaking;
                                _tts.speak(m.text);
                                _tts.setCompletionHandler(() {
                                  setState(() {
                                    m.state = BotMessageState.CanPlay;
                                  });
                                });
                              });
                            },
                            icon: const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Icon(
                                Icons.play_circle_outline_rounded,
                                color: Colors.orange,
                                size: 28,
                              ),
                            ),
                          )
                        : null);
  }

  void _send(String prompt) async {
    setState(
      () {
        _messages.add(
          Message(
              sender: MessageSender.User,
              text: prompt,
              time: timeFormat.format(DateTime.now())),
        );
        _textEditingController.clear();
      },
    );
    Future.delayed(const Duration(milliseconds: 50)).then((_) => _scrollDown());
    final request =
        CompleteText(prompt: prompt, maxTokens: 100, model: kTextDavinci3);
    CTResponse? response = await openAI.onCompletion(request: request);
    String result =
        response?.choices.first.text.replaceAll('\n', '') ?? 'Error';

    Message newMessage = Message(
        sender: MessageSender.Bot,
        text: result,
        time: timeFormat.format(DateTime.now()),
        state: _autoTTS ? BotMessageState.Speaking : BotMessageState.CanPlay);

    _saveMessages();

    setState(() {
      _messages.add(newMessage);

      if (newMessage.state == BotMessageState.Speaking) {
        _tts.speak(newMessage.text);
        _tts.setCompletionHandler(() {
          setState(() {
            newMessage.state = BotMessageState.CanPlay;
          });
        });
      }

      Future.delayed(const Duration(milliseconds: 50))
          .then((_) => _scrollDown());
    });
  }

  void _saveMessages() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(MESSAGES_PREF_KEY, Message.encode(_messages));
  }

  Future<List<Message>> _loadMessages() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? messagesString = prefs.getString(MESSAGES_PREF_KEY);
    List<Message> messages =
        messagesString != null ? Message.decode(messagesString) : <Message>[];

    return messages;
  }

  void _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(DARK_MODE_PREF_KEY, _darkMode);
    await prefs.setBool(AUTO_TTS_PREF_KEY, _autoTTS);
    await prefs.setBool(LANGUAGE_PREF_KEY, Get.locale?.countryCode == 'US');
    await prefs.setBool(TOUCH_TO_SPEAK_PREF_KEY, _speechOptions[0]);
  }

  void _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool darkMode = prefs.getBool(DARK_MODE_PREF_KEY) ?? false;
    final bool autoTTS = prefs.getBool(AUTO_TTS_PREF_KEY) ?? true;
    final bool isEnLanguage = prefs.getBool(LANGUAGE_PREF_KEY) ?? true;
    final bool isTouchMode = prefs.getBool(TOUCH_TO_SPEAK_PREF_KEY) ?? false;

    setState(() {
      _darkMode = darkMode;
      Get.changeTheme(darkMode ? MyApp.darkTheme : MyApp.lightTheme);

      _autoTTS = autoTTS;

      if (isEnLanguage) {
        Get.updateLocale(const Locale('en', 'US'));
      } else {
        Get.updateLocale(const Locale('vn', 'VN'));
      }

      _speechOptions[0] = isTouchMode;
      _speechOptions[1] = !isTouchMode;
      _updateHintText();
    });
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _buildConfirmRemoveHistoryDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
            backgroundColor: _darkMode ? Colors.grey[900] : Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Remove history?',
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                      'Are you sure you want to delete the conversation? You cannot undo this action.'),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        width: 85,
                        child: OutlinedButton(
                          onPressed: () {
                            _messages = <Message>[];
                            _saveMessages();
                            setState(() {});
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            side: const BorderSide(color: Colors.redAccent),
                            foregroundColor: Colors.redAccent,
                          ),
                          child: const Text("Remove"),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 85,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            elevation: 0,
                          ),
                          child: const Text("Cancel"),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )));
  }
}
