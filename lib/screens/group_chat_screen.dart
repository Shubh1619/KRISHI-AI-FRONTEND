import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({super.key});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsersFromLogin();
  }

  Future<void> loadUsersFromLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('loginResponse');

    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ वापरकर्ता माहिती सापडली नाही')),
      );
      return;
    }

    try {
      final decoded = jsonDecode(userData);
      final List<dynamic> allUsers = decoded['users'];
      final int currentUserId = decoded['user_id'];

      // Remove current user from list
      allUsers.removeWhere((user) => user['id'] == currentUserId);

      setState(() {
        users = allUsers;
        isLoading = false;
      });
    } catch (e) {
      print("Decode error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ डेटा प्रक्रिया करताना त्रुटी आली')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: const Text('समूह चर्चा', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : users.isEmpty
              ? const Center(child: Text('❗️ इतर शेतकरी सापडले नाहीत'))
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo[100],
                        child: const Icon(
                          Icons.person,
                          color: Color.fromRGBO(76, 175, 80, 1),
                        ),
                      ),
                      title: Text(
                        user['name'] ?? 'नाव नाही',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(
                        Icons.chat,
                        color: Color.fromRGBO(76, 175, 80, 1),
                      ),
                      onTap: () {
                        // 🔄 Navigate to ChatScreen(user)
                      },
                    ),
                  );
                },
              ),
    );
  }
}
