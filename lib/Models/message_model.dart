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
}

enum MessageSender { User, Bot }

enum BotMessageState {
  Null,
  Loading,
  Speaking,
  CanPlay,
}
