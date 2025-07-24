import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String recipientUserId;
  final String recipientUserName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.recipientUserId,
    required this.recipientUserName,
  });

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
    fetchChatHistory();
    connectWebSocket();
  }

  void connectWebSocket() {
    final uri = Uri.parse(
      'ws://3.108.54.131:8000/ws/chat/${widget.recipientUserId}?user_id=${widget.currentUserId}',
    );

    print("🔗 Connecting to WebSocket: $uri");
    channel = WebSocketChannel.connect(uri);

    channel.stream.listen(
      (data) {
        print("📩 Message received: $data");
        final decoded = jsonDecode(data);
        final from = decoded['from'] ?? '';
        final msg = decoded['message'] ?? '';
        setState(() {
          messages.add({'from': from, 'message': msg});
        });
      },
      onError: (error) {
        print("❌ WebSocket error: $error");
      },
      onDone: () {
        print("🔌 WebSocket connection closed.");
      },
    );
  }

  void fetchChatHistory() async {
    final url = Uri.parse(
      'http://3.108.54.131:8000/chat/history/${widget.currentUserId}/${widget.recipientUserId}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> history = jsonDecode(response.body);
        setState(() {
          messages.clear();
          messages.addAll(
            history.map<Map<String, String>>((e) {
              final from = e['from'] ?? '';
              final encodedMessage = e['message'] ?? '';
              String decodedMsg = '[unreadable]';
              try {
                decodedMsg = utf8.decode(base64.decode(encodedMessage));
              } catch (_) {}
              return {'from': from, 'message': decodedMsg};
            }).toList(),
          );
        });
      } else {
        print("❌ Failed to load history: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching history: $e");
    }
  }

  void sendMessage() {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;

    final data = jsonEncode({
      'from': widget.currentUserId,
      'message': msg,
    });
    channel.sink.add(data);
    _controller.clear();
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    _controller.dispose();
    super.dispose();
  }

  bool isSentByMe(String fromId) => fromId == widget.currentUserId.toString();

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
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.green[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['message'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
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
                  icon: const Icon(
                    Icons.send,
                    color: Color.fromRGBO(76, 175, 80, 1),
                  ),
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