class Message {
  final String text;
  final bool isUser;
  final String time;
  final MessageState state;

  Message({
    required this.isUser,
    this.text = '',
    this.time = '00:00',
    this.state = MessageState.Null,
  });
}

enum MessageState{
  Null, Loading, Speaking, CanPlay, Recording,
}