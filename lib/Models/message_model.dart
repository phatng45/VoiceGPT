class Message {
  final String text;
  final bool isUser;
  final String time;

  Message({
    required this.isUser,
    this.text = '',
    this.time = '00:00',
  });
}
