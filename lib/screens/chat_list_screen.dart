import 'package:flutter/material.dart';
import '../widgets/common/app_scaffold.dart';
import '../widgets/chat_list/chat_list_view.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Messages',
      currentIndex: 1, // Chat tab index
      child: const ChatListView(),
    );
  }
}