import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/colors.dart';
import '../models/chat_room.dart';
import '../models/message.dart';
import '../widgets/chat/chat_message_bubble.dart';
import '../widgets/chat/chat_input.dart';
import '../widgets/chat/chat_header.dart';
import '../widgets/chat/day_separator.dart';
import '../services/chat_service.dart';
import '../services/service_provider.dart';
import '../utils/message_utils.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoom chat;

  const ChatScreen({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ChatService _chatService = ServiceProvider().getChatService();
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  int? _beforeId;
  bool _isMarkingAsRead = false;
  bool _hasMarkedAsRead = false;
  bool _isSendingMessage = false;
  
  // Store messages with sending errors for retry
  final Map<String, String> _failedMessages = {};

  // Parse room ID safely
  int get _roomId {
    return widget.chat.idAsInt;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMessages();
    // Mark as read only once when entering chat room
    _markAsRead();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh messages when app is resumed
      _loadMessages();
    }
  }

  Future<void> _markAsRead() async {
    // Don't start another mark as read operation if one is already in progress
    // or if we've already marked messages as read
    if (_isMarkingAsRead || _hasMarkedAsRead) return;
    
    try {
      // Set internal flag but don't update UI
      _isMarkingAsRead = true;
      
      final result = await _chatService.markAsRead(_roomId);
      
      if (result['success'] == true) {
        // Update the UI to reflect that messages are read
        if (mounted) {
          setState(() {
            // Count how many messages were updated
            int updatedCount = 0;
            
            // Update all unread messages to be read
            for (int i = 0; i < _messages.length; i++) {
              if (!_messages[i].isMe && !_messages[i].isRead) {
                _messages[i] = _messages[i].copyWith(
                  isRead: true,
                  readAt: DateTime.now(),
                );
                updatedCount++;
              }
            }
            
            _isMarkingAsRead = false;
            _hasMarkedAsRead = true;
          });
        }
      } else {
        if (mounted) {
          _isMarkingAsRead = false;
        }
      }
    } catch (e) {
      if (mounted) {
        _isMarkingAsRead = false;
      }
    }
  }

  Future<void> _loadMessages({bool loadMore = false}) async {
    if (loadMore && (!_hasMoreMessages || _isLoadingMore)) {
      return;
    }

    if (!mounted) return;

    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        // Reset beforeId when doing a fresh load (not pagination)
        _beforeId = null;
      }
      _hasError = false;
    });

    try {
      final result = await _chatService.getMessages(
        _roomId,
        beforeId: loadMore ? _beforeId : null,
      );

      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      if (result['success'] == true) {
        final data = result['data'];
        final List<Message> newMessages = [];

        if (data is List) {
          for (var msg in data) {
            try {
              newMessages.add(Message.fromJson(msg));
            } catch (e) {
              print('Error parsing message: $e');
            }
          }
          
          // Sort messages by createdAt in ascending order (oldest first)
          newMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        }

        setState(() {
          if (loadMore) {
            // When loading more (older) messages, add them at the beginning
            _messages.insertAll(0, newMessages);
            _isLoadingMore = false;
          } else {
            _messages = newMessages;
            _isLoading = false;
          }

          // Use the has_more field from the API response if available
          _hasMoreMessages = result.containsKey('has_more') 
              ? result['has_more'] 
              : newMessages.isNotEmpty;
              
          if (newMessages.isNotEmpty && loadMore) {
            // When loading more, use the oldest message's ID for pagination
            _beforeId = newMessages.isEmpty ? null : int.tryParse(newMessages.first.id);
          } else if (newMessages.isNotEmpty) {
            // For initial load, we want the oldest message ID for future pagination
            _beforeId = newMessages.isEmpty ? null : int.tryParse(newMessages.first.id);
          }
        });
        
        // Mark messages as read after loading them
        if (!loadMore) {
          _markAsRead();
        }
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = result['message'] ?? 'Failed to load messages';
          if (loadMore) {
            _isLoadingMore = false;
          } else {
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      // Check if widget is still mounted before calling setState
      if (!mounted) return;
      
      setState(() {
        _hasError = true;
        _errorMessage = MessageUtils.getUserFriendlyErrorMessage(e);
        if (loadMore) {
          _isLoadingMore = false;
        } else {
          _isLoading = false;
        }
      });
    }
  }

  void _handleSendMessage(String content) async {
    if (content.trim().isEmpty || _isSendingMessage) return;

    // Generate a unique ID for the temporary message
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Create a temporary message for optimistic UI update
    final tempMessage = Message(
      id: tempId,
      chatRoomId: widget.chat.id.toString(),
      senderId: 'current_user_id', // This will make isMe return true
      content: content,
      createdAt: DateTime.now(),
      senderName: 'You',
      isGuide: false,
    );

    if (!mounted) return;

    setState(() {
      // Add new message at the end (newest at the bottom)
      _messages.add(tempMessage);
      _isSendingMessage = true;
    });

    try {
      final result = await _chatService.sendMessage(
        _roomId,
        content,
      );

      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      if (result['success'] == true) {
        // Replace the temporary message with the real one
        final realMessage = Message.fromJson(result['data']);
        setState(() {
          final index = _messages.indexWhere((msg) => msg.id == tempId);
          if (index != -1) {
            _messages[index] = realMessage;
          }
          _isSendingMessage = false;
          
          // Remove from failed messages if it was there
          _failedMessages.remove(tempId);
        });
        
        // Mark messages as read after sending a message
        _markAsRead();
      } else {
        // Show error state for the message
        setState(() {
          final index = _messages.indexWhere((msg) => msg.id == tempId);
          if (index != -1) {
            // Mark message as failed but keep it in the UI
            _failedMessages[tempId] = content;
          }
          _isSendingMessage = false;
        });
        
        MessageUtils.showErrorSnackBar(
          context, 
          'Failed to send message. Tap to retry.',
          onRetry: () => _retryAllFailedMessages(),
        );
      }
    } catch (e) {
      // Check if widget is still mounted before calling setState
      if (!mounted) return;
      
      setState(() {
        final index = _messages.indexWhere((msg) => msg.id == tempId);
        if (index != -1) {
          // Mark message as failed but keep it in the UI
          _failedMessages[tempId] = content;
        }
        _isSendingMessage = false;
      });
      
      MessageUtils.showErrorSnackBar(
        context, 
        MessageUtils.getUserFriendlyErrorMessage(e),
        onRetry: () => _retryAllFailedMessages(),
      );
    }
  }
  
  void _retrySendMessage(String messageId) {
    if (!_failedMessages.containsKey(messageId)) return;
    
    final content = _failedMessages[messageId]!;
    
    // Remove the failed message
    setState(() {
      _messages.removeWhere((msg) => msg.id == messageId);
      _failedMessages.remove(messageId);
    });
    
    // Try sending it again
    _handleSendMessage(content);
  }
  
  void _retryAllFailedMessages() {
    if (_failedMessages.isEmpty) return;
    
    // Create a copy to avoid concurrent modification
    final messagesToRetry = Map<String, String>.from(_failedMessages);
    for (final entry in messagesToRetry.entries) {
      _retrySendMessage(entry.key);
    }
  }

  List<Widget> _buildMessageList() {
    if (_messages.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No messages yet. Start the conversation!',
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 16,
              ),
            ),
          ),
        )
      ];
    }

    final List<Widget> messageWidgets = [];
    String? currentDate;

    // Messages are already sorted (oldest first), so iterate normally
    for (int i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      final messageDate = message.formattedDate;
      
      // Check if this is a failed message
      final bool isFailed = _failedMessages.containsKey(message.id);

      // Add date separator if date changes
      if (messageDate != currentDate) {
        messageWidgets.add(DaySeparator(day: messageDate));
        currentDate = messageDate;
      }

      // Create message bubble with tap handler for failed messages
      final messageBubble = isFailed
          ? GestureDetector(
              onTap: () => _retrySendMessage(message.id),
              child: Stack(
                children: [
                  ChatMessageBubble(message: message),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ChatMessageBubble(message: message);
      
      messageWidgets.add(messageBubble);
    }

    // Add load more button at the top if there are more messages
    if (_hasMoreMessages) {
      messageWidgets.insert(
        0,
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: _isLoadingMore
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: () => _loadMessages(loadMore: true),
                    child: const Text('Load more messages'),
                  ),
          ),
        ),
      );
    }

    return messageWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ChatHeader(
        userName: widget.chat.userName,
        userLocation: widget.chat.location ?? 'Unknown location',
        rating: widget.chat.rating ?? 4.5,
        profilePicture: widget.chat.profilePicture,
        isOnline: widget.chat.isOnline,
      ),
      body: Column(
        children: [
          // Remove the loading indicator for marking messages as read
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Error loading messages',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.gray600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadMessages,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary800,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          // Reset pagination and do a fresh load
                          setState(() {
                            _beforeId = null;
                            _hasMoreMessages = true;
                            // Reset marked as read flag to allow marking again on refresh
                            _hasMarkedAsRead = false;
                          });
                          await _loadMessages();
                          // Will only trigger if _hasMarkedAsRead is false
                          await _markAsRead();
                        },
                        color: AppColors.primary800,
                        child: ListView(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          children: _buildMessageList(),
                        ),
                      ),
          ),
          ChatInput(
            onSendMessage: _handleSendMessage,
            isSending: _isSendingMessage,
          ),
        ],
      ),
    );
  }
}