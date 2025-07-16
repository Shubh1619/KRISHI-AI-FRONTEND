import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  Future<void> _launchFAQ() async {
    const faqUrl = 'https://krishiai.help/faq';
    final Uri uri = Uri.parse(faqUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp() async {
    final Uri uri = Uri.parse("https://wa.me/+918856832687");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'krishiai.project@gmail.com',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'मदत व सपोर्ट',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[800],
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: const [
                Icon(Icons.support_agent, size: 40, color: Colors.green),
                SizedBox(height: 8),
                Text(
                  'आम्ही येथे आहोत तुमच्या मदतीसाठी!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'कृपया खालील पर्याय वापरा तुमच्या शंकांचे निरसन करण्यासाठी.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSupportTile(
            context,
            icon: Icons.help_outline,
            title: 'FAQ (सामान्य प्रश्न)',
            subtitle: 'सर्वसामान्य शंकांची उत्तरे वाचा',
            onTap: _launchFAQ,
          ),
          const SizedBox(height: 12),
          _buildSupportTile(
            context,
            icon: Icons.email_outlined,
            title: 'ईमेल पाठवा',
            subtitle: 'आपली शंका ईमेलद्वारे पाठवा',
            onTap: _launchEmail,
          ),
          const SizedBox(height: 12),
          _buildSupportTile(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'व्हॉट्सअ‍ॅप समर्थन',
            subtitle: 'थेट गप्पा मारा आमच्या टीमसोबत',
            onTap: _launchWhatsApp,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSupportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Function() onTap,
  }) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
