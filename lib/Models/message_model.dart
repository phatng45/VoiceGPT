import 'dart:convert';

class Message {
  final String text;
  final MessageSender sender;
  final String time;
  late BotMessageState state;

  bool isUser() => sender == MessageSender.User;

  Message({
    required this.sender,
    this.text = '',
    this.time = '00:00',
    this.state = BotMessageState.CanPlay,
  });

  factory Message.fromJson(Map<String, dynamic> jsonData) {
    return Message(
      text: jsonData['text'],
      sender: jsonData['sender'],
      time: jsonData['time'],
      state: jsonData['state'],
    );
  }

  static Map<String, dynamic> toMap(Message msg) => {
        'text': msg.text,
        'sender': msg.sender,
        'time': msg.time,
        'state': msg.state,
      };

  static String encode(List<Message> msgs) => json.encode(
        msgs.map<Map<String, dynamic>>((msg) => Message.toMap(msg)).toList(),
      );

  static List<Message> decode(String msgs) =>
      (json.decode(msgs) as List<dynamic>)
          .map<Message>((item) => Message.fromJson(item))
          .toList();
}

enum MessageSender { User, Bot }

enum BotMessageState {
  Null,
  Loading,
  Speaking,
  CanPlay,
}
