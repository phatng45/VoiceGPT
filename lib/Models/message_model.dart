class Message {
  final String text;
  final bool isUser;
  final String time;
  final SystemMessageState state;

  Message({
    required this.isUser,
    this.text = '',
    this.time = '00:00',
    this.state = SystemMessageState.Null});
}

enum SystemMessageState{
Null, Loading, Speaking, CanPlay,
}