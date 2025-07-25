import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
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
  String token = '';

  @override
  void initState() {
    super.initState();
    loadCurrentUserAndFetchUsers();
  }

  Future<void> loadCurrentUserAndFetchUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final loginResponse = prefs.getString('loginResponse');

    if (loginResponse != null) {
      try {
        final data = jsonDecode(loginResponse);
        currentUserId = data['user_id']?.toString() ?? '';
        currentUserName = data['name'] ?? '';
        token = data['token'] ?? '';

        print('🧾 Login user: $currentUserName ($currentUserId)');
        print('🔐 Token: $token');

        await fetchUsersFromApi();
      } catch (e) {
        print('❌ Error parsing login data: $e');
      }
    } else {
      print('❌ loginResponse not found in SharedPreferences');
    }
  }

  Future<void> fetchUsersFromApi() async {
    const url = 'http://3.7.254.249:8000/auth/auth/users';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> allUsers = jsonDecode(response.body);
        setState(() {
          users = allUsers;
        });

        for (var user in allUsers) {
          print('👥 User: ${user['name']} (${user['id']})');
        }
      } else {
        print('❌ Failed to fetch users: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final otherUsers =
        users.where((u) => u['id'].toString() != currentUserId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('समूह चर्चा'),
        backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
      ),
      body:
          otherUsers.isEmpty
              ? const Center(child: Text("No other users available"))
              : ListView.builder(
                itemCount: otherUsers.length,
                itemBuilder: (context, index) {
                  final user = otherUsers[index];
                  final userId = user['id'].toString();
                  final userName =
                      user['name']?.toString().trim() ?? 'नाव नाही';

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
                        print('📲 Tapped on: $userName ($userId)');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ChatScreen(
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
