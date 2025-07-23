import 'package:flutter/material.dart';
import 'crop_disease_detection.dart';
import 'weather_details.dart';
import 'login_page.dart';
import 'market_price.dart';
import 'gov_schemes.dart';
import 'help_support.dart';
import 'group_chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatelessWidget {
  final String farmerName;
  final bool isDark;
  final VoidCallback toggleTheme;

  const MainPage({
    super.key,
    required this.farmerName,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'icon': Icons.camera_alt,
        'color': Colors.green,
        'title': 'पिक रोग शोध',
        'subtitle': 'एआय-आधारित रोग ओळख',
        'onTap':
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CropDiseaseDetectionPage(),
              ),
            ),
      },
      {
        'icon': Icons.show_chart,
        'color': Colors.blue,
        'title': 'मंडी दर',
        'subtitle': 'थेट बाजार दर व ट्रेंड्स',
        'onTap':
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MandiPricesScreen()),
            ),
      },

      {
        'icon': Icons.wb_sunny_outlined,
        'color': Colors.orange,
        'title': 'हवामान सल्ला',
        'subtitle': 'शेतीसाठी हवामान माहिती',
        'onTap':
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WeatherDetailsPage(),
              ),
            ),
      },
      {
        'icon': Icons.description,
        'color': Colors.purple,
        'title': 'सरकारी योजना',
        'subtitle': 'शेतकऱ्यांसाठी योजना',
        'onTap':
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SchemesScreen()),
            ),
      },
      {
        'icon': Icons.forum,
        'color': Colors.indigo,
        'title': 'समूह चर्चा',
        'subtitle': 'शेतकरी एकत्र जोडा',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GroupChatPage()),
          );
        },
      },
      {
        'icon': Icons.calculate,
        'color': Colors.teal,
        'title': 'कॅल्क्युलेटर टूल्स',
        'subtitle': 'खते व बियाणे गणना',
        'onTap': () {},
      },
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'नमस्कार शेतकरी 🌾',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    farmerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('प्रोफाइल'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('प्रोफाइल पेज लवकरच येईल')),
                );
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.settings),
              title: const Text('सेटिंग्ज'),
              children: [
                ListTile(
                  leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  title: const Text('थीम बदला'),
                  onTap: () {
                    toggleTheme();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('सूचना'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('मदत व सपोर्ट'),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportPage(),
                        ),
                      ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('लॉगआउट'),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder:
                            (context) => LoginPage(
                              isDark: isDark,
                              toggleTheme: toggleTheme,
                            ),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("आमच्या सेवा"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'आमच्या सेवा',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'शेतकऱ्यांसाठी खास डिझाइन केलेले टूल्स',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: services.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return GestureDetector(
                    onTap: service['onTap'] as void Function()?,
                    child: _ServiceCard(
                      icon: service['icon'] as IconData,
                      color: service['color'] as Color,
                      title: service['title'] as String,
                      subtitle: service['subtitle'] as String,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _ServiceCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}