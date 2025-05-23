import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSend;

  const ChatInput({
    Key? key,
    this.controller,
    this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: controller,
                style: chatMessageTextStyle.copyWith(
                  color: AppColors.inputText,
                ),
                decoration: const InputDecoration(
                  hintText: 'Message',
                  hintStyle: inputHintTextStyle,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.sendButton,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () {
                  if (controller?.text.trim().isNotEmpty ?? false) {
                    onSend?.call();
                    controller?.clear();
                  }
                },
                child: const Center(
                  child: Icon(
                    Icons.send,
                    color: AppColors.iconColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}