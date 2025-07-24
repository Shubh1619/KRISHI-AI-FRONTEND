import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String recipientUserId;
  final String recipientUserName;

  const ChatScreen({
    Key? key,
    required this.currentUserId,
    required this.currentUserName,
    required this.recipientUserId,
    required this.recipientUserName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late WebSocketChannel channel;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    final uri = Uri.parse(
      // 'wss://krushi-ai.onrender.com/ws/chat/${widget.recipientUserId}?user_id=${widget.currentUserId}',
      'wss://13.234.76.137:8000/ws/chat/${widget.recipientUserId}?user_id=${widget.currentUserId}',
    );

    print("🔗 Connecting to WebSocket: $uri");

    channel = WebSocketChannel.connect(uri);

    channel.stream.listen((data) {
      print("📩 Message received: $data");
      final decoded = jsonDecode(data);
      final from = decoded['from'] ?? '';
      final msg = decoded['message'] ?? '';
      setState(() {
        messages.add({
          'from': from,
          'message': msg,
        });
      });
    }, onError: (error) {
      print("❌ WebSocket error: $error");
    }, onDone: () {
      print("🔌 WebSocket connection closed.");
    });
  }

  void sendMessage() {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;

    final data = jsonEncode({
      'from': widget.currentUserId,
      'message': msg,
    });

    channel.sink.add(data);

    setState(() {
      messages.add({
        'from': widget.currentUserId,
        'message': msg,
      });
      _controller.clear();
    });
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    _controller.dispose();
    super.dispose();
  }

  bool isSentByMe(String fromId) => fromId == widget.currentUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientUserName),
        backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = isSentByMe(message['from'] ?? '');
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.green[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message['message'] ?? ''),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color.fromRGBO(76, 175, 80, 1)),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
