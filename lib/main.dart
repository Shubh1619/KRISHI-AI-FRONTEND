import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;
  bool _isLoggedIn = false;
  String _farmerName = '';
  bool _loading = true;

  void toggleTheme() => setState(() => isDark = !isDark);

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final name = prefs.getString('farmerName') ?? '';
    setState(() {
      _isLoggedIn = isLoggedIn;
      _farmerName = name;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      title: 'Krishi AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home:
          _isLoggedIn && _farmerName.isNotEmpty
              ? MainPage(
                farmerName: _farmerName,
                isDark: isDark,
                toggleTheme: toggleTheme,
              )
              : HomePage(isDark: isDark, toggleTheme: toggleTheme),
    );
  }
}
