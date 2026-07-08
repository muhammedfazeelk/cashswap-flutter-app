import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  final String roomId;
  final Map<String, dynamic> matchData;

  const ChatPage({super.key, required this.roomId, required this.matchData});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  WebSocketChannel? _channel;
  final List<_ChatMsg> _messages = [];
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  String? _currentUserId;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _currentUserId = await SecureStore.getUserId();
    final token = await SecureStore.getToken();
    _connectWebSocket(token!);
  }

  void _connectWebSocket(String token) {
    final uri = Uri.parse(
        '${AppConfig.wsBaseUrl}/ws/chat/${widget.roomId}?token=$token');
    _channel = WebSocketChannel.connect(uri);

    setState(() => _isConnected = true);

    _channel!.stream.listen(
      (raw) {
        final data = json.decode(raw as String) as Map<String, dynamic>;
        _handleMessage(data);
      },
      onDone: () {
        setState(() => _isConnected = false);
        // Reconnect after 3s
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _init();
        });
      },
      onError: (e) {
        debugPrint('WebSocket error: $e');
        setState(() => _isConnected = false);
      },
    );
  }

  void _handleMessage(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type == 'history') {
      final msgs = (data['messages'] as List?)
              ?.map((m) => _ChatMsg.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [];
      setState(() => _messages.addAll(msgs));
      _scrollToBottom();
    } else if (type == 'message') {
      setState(() => _messages.add(_ChatMsg.fromJson(data)));
      _scrollToBottom();
    } else if (type == 'user_joined' || type == 'user_left') {
      setState(() => _messages.add(_ChatMsg.system(
            type == 'user_joined' ? 'Partner joined the chat' : 'Partner left the chat',
          )));
    }
  }

  void _send() {
    final text = _msgController.text.trim();
    if (text.isEmpty || !_isConnected) return;
    _channel?.sink.add(json.encode({'type': 'text', 'content': text}));
    _msgController.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Swap Chat'),
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: _isConnected ? AppTheme.success : AppTheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isConnected ? 'Connected' : 'Reconnecting...',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _showCompleteDialog,
            child: const Text('Complete Swap',
                style: TextStyle(color: AppTheme.primary, fontFamily: 'Sora')),
          ),
        ],
      ),
      body: Column(
        children: [
          // Match info banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.surfaceAlt,
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Meet safely in a public place. Verify amount before completing.',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _MessageBubble(
                msg: _messages[i],
                isMe: _messages[i].senderId == _currentUserId,
              ),
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: AppTheme.surfaceAlt,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      onSubmitted: (_) => _send(),
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontFamily: 'Sora'),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: AppTheme.card,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44, height: 44,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceAlt,
        title: const Text('Complete Swap?', style: AppTextStyles.heading2),
        content: const Text(
          'Confirm that you have successfully exchanged money with your partner.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Call match complete API then go to rating page
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  final String? senderId;
  final String content;
  final String type; // "text" | "system"
  final DateTime createdAt;

  _ChatMsg({this.senderId, required this.content, this.type = 'text', required this.createdAt});

  factory _ChatMsg.fromJson(Map<String, dynamic> json) => _ChatMsg(
        senderId: json['sender_id'] as String?,
        content: json['content'] as String? ?? '',
        type: json['message_type'] as String? ?? 'text',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  factory _ChatMsg.system(String text) => _ChatMsg(
        content: text,
        type: 'system',
        createdAt: DateTime.now(),
      );
}

class _MessageBubble extends StatelessWidget {
  final _ChatMsg msg;
  final bool isMe;

  const _MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    if (msg.type == 'system') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(msg.content, style: AppTextStyles.caption),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary : AppTheme.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.content,
              style: TextStyle(
                color: isMe ? Colors.black : AppTheme.textPrimary,
                fontFamily: 'Sora',
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeago.format(msg.createdAt),
              style: TextStyle(
                color: isMe ? Colors.black54 : AppTheme.textSecondary,
                fontSize: 10,
                fontFamily: 'Sora',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
