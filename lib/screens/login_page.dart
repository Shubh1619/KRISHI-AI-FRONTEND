import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
import 'registration_page.dart';
import 'forget_pass.dart';

class LoginPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const LoginPage({super.key, required this.isDark, required this.toggleTheme});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final name = prefs.getString('farmerName') ?? '';

    if (isLoggedIn && name.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => MainPage(
                farmerName: name,
                isDark: widget.isDark,
                toggleTheme: widget.toggleTheme,
              ),
        ),
      );
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://krushi-ai.onrender.com/auth/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['name'] != null) {
        final prefs = await SharedPreferences.getInstance();

        // ✅ Save required individual values
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('farmerName', data['name']);

        // ✅ Save entire response for group chat
        await prefs.setString('loginResponse', jsonEncode(data));

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ यशस्वीपणे लॉगिन झाले')));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => MainPage(
                  farmerName: data['name'],
                  isDark: widget.isDark,
                  toggleTheme: widget.toggleTheme,
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? '❌ लॉगिन अयशस्वी')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ त्रुटी: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('लॉगिन करा'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'ईमेल',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'ईमेल आवश्यक आहे' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'पासवर्ड',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) => value!.isEmpty ? 'पासवर्ड आवश्यक आहे' : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'पासवर्ड विसरलात?',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text('लॉगिन', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegistrationPage()),
                  );
                },
                child: const Text(
                  'खाते नाही? नोंदणी करा',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}