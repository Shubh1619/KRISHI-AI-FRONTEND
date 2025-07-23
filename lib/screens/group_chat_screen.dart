import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({Key? key}) : super(key: key);

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  List<dynamic> users = [];
  String currentUserId = '';
  String currentUserName = '';

  @override
  void initState() {
    super.initState();
    loadUsersFromPrefs();
  }

  Future<void> loadUsersFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final loginResponse = prefs.getString('loginResponse');

  if (loginResponse != null) {
    try {
      final data = jsonDecode(loginResponse);
      print('🧾 Raw loginResponse: $data');

      final allUsers = data['users'] ?? [];
      final extractedUserId = data['user_id'];
      final extractedUserName = data['name'];

      setState(() {
        users = allUsers;
        currentUserId = extractedUserId?.toString() ?? '';
        currentUserName = extractedUserName ?? '';
      });

      print('✅ Extracted Current User ID: $currentUserId');
      print('✅ Extracted Current User Name: $currentUserName');

      for (var user in allUsers) {
        print('👥 Found user: ${user['name']} (${user['id']})');
      }
    } catch (e) {
      print('❌ Error decoding loginResponse: $e');
    }
  } else {
    print('❌ loginResponse not found in SharedPreferences');
  }
}


  @override
  Widget build(BuildContext context) {
    final otherUsers = users.where((u) => u['id'].toString() != currentUserId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('समूह चर्चा'),
        backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
      ),
      body: otherUsers.isEmpty
          ? const Center(child: Text("No other users available"))
          : ListView.builder(
              itemCount: otherUsers.length,
              itemBuilder: (context, index) {
                final user = otherUsers[index];
                final userId = user['id'].toString();
                final userName = user['name']?.toString().trim() ?? 'नाव नाही';

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo[100],
                      child: const Icon(
                        Icons.person,
                        color: Color.fromRGBO(76, 175, 80, 1),
                      ),
                    ),
                    title: Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(
                      Icons.chat,
                      color: Color.fromRGBO(76, 175, 80, 1),
                    ),
                    onTap: () {
                      print('📲 Tapped on user: $userName ($userId)');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            currentUserId: currentUserId,
                            currentUserName: currentUserName,
                            recipientUserId: userId,
                            recipientUserName: userName,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
