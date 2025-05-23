class Message {
  final String text;
  final String time;
  final bool isMe;
  final String senderName;
  final String? day; // Optional day separator

  Message({
    required this.text,
    required this.time,
    required this.isMe,
    required this.senderName,
    this.day,
  });
}

// Sample data
final List<Message> messages = [
  Message(
    text: "Thanks everyone! Almost there.",
    time: "10:16am",
    isMe: false,
    senderName: "Ahmed El Yassifi",
    day: "Thursday",
  ),
  Message(
    text: "Hey team, I've finished with the requirements doc!",
    time: "11:40am",
    isMe: false,
    senderName: "Ahmed El Yassifi",
  ),
  Message(
    text: "Awesome! Thanks.",
    time: "11:41am",
    isMe: true,
    senderName: "You",
  ),
  Message(
    text: "Hey Olivia, can you please review the latest design when you can?",
    time: "2:20pm",
    isMe: false,
    senderName: "Ahmed El Yassifi",
    day: "Friday",
  ),
];