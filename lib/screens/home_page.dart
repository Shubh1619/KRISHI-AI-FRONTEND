import 'package:flutter/material.dart';
import 'login_page.dart';
import 'contact_page.dart';

class HomePage extends StatelessWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const HomePage({super.key, required this.isDark, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("कृषी AI"),
        backgroundColor: Colors.green,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        color: isDark ? Colors.black : const Color(0xFFF0FFF6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 280,
                height: 210,
                child: Image.asset('assets/farmer.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 24),

            /// Headline
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "स्मार्ट ",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const TextSpan(
                    text: "शेतीचा नवा साथी — ",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "'शेतकऱ्याचा मित्र' ",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  TextSpan(
                    text: "तुमच्यासाठी! ",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 20),

            /// Subheading
            Text(
              "पिकांची काळजी, बाजारभाव आणि आधुनिक कृषी सल्ला यासाठी AI चा वापर करा.",
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[300] : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            /// Buttons Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => LoginPage(
                              isDark: isDark,
                              toggleTheme: toggleTheme,
                            ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("लॉगिन करा"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text("संपर्क"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
