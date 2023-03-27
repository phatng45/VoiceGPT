class Message {
  final String text;
  final MessageSender sender;
  final String time;
  final BotMessageState state;

 bool isUser() => sender == MessageSender.User;

  Message({
    required this.sender,
    this.text = '',
    this.time = '00:00',
    this.state = BotMessageState.Null,
  });
}

enum MessageSender { User, Bot }

enum BotMessageState {
  Null,
  Loading,
  Speaking,
  CanPlay,
}
