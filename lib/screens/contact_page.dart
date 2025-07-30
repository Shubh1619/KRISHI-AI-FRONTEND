import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _launchPhone(BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '8856832687');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('फोन लाँच करणे शक्य नाही')));
    }
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'krishiai.project@gmail.com',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ईमेल लाँच करणे शक्य नाही')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'आमच्याशी संपर्क साधा',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[800],
        elevation: 10,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header with Image
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Image.asset('assets/farmer.png', height: 100),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'कृषी AI',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'शेतकऱ्यांसाठी AI-आधारित समाधाने. आम्ही पीक निदान, बाजारभाव आणि हवामान सल्ला सेवा पुरवतो.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards with Icons
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              children: const [
                _StatCard(
                  icon: Icons.people,
                  title: '५०K+',
                  subtitle: 'आनंदी शेतकरी',
                ),
                _StatCard(
                  icon: Icons.verified,
                  title: '९५%',
                  subtitle: 'अचूकता दर',
                ),
                _StatCard(
                  icon: Icons.support_agent,
                  title: '२४/७',
                  subtitle: 'सपोर्ट',
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: 'आमच्या सेवा',
              icon: Icons.agriculture,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _ServiceChip(
                    icon: Icons.medical_services,
                    label: 'रोग ओळख',
                    color: Colors.orange,
                  ),
                  _ServiceChip(
                    icon: Icons.attach_money,
                    label: 'बाजारभाव',
                    color: Colors.green,
                  ),
                  _ServiceChip(
                    icon: Icons.cloud,
                    label: 'हवामान सल्ला',
                    color: Colors.blue,
                  ),
                  _ServiceChip(
                    icon: Icons.lightbulb,
                    label: 'शेती सल्ला',
                    color: Colors.purple,
                  ),
                  _ServiceChip(
                    icon: Icons.gavel,
                    label: 'सरकारी योजना',
                    color: Colors.teal,
                  ),
                  _ServiceChip(
                    icon: Icons.group,
                    label: 'समूह चर्चा',
                    color: Colors.indigo,
                  ),
                  _ServiceChip(
                    icon: Icons.science,
                    label: 'खतांचा सल्ला',
                    color: Colors.brown,
                  ),
                  _ServiceChip(
                    icon: Icons.smart_toy, // You can also use Icons.robot
                    label: 'AI सहाय्यक',
                    color: Colors.pinkAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: 'संपर्क माहिती',
              icon: Icons.contact_phone,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: const Text('फोन'),
                      subtitle: const Text('८८५६८३२६८७'),
                      trailing: IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => _launchPhone(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: const Text('ईमेल'),
                      subtitle: const Text('krishiai.project@gmail.com'),
                      trailing: IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: () => _launchEmail(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: 'संदेश पाठवा',
              icon: Icons.message,
              child: const _ContactForm(),
            ),

            // Footer
            Container(
              margin: const EdgeInsets.only(top: 30),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: Text(
                  '© २०२४ कृषी AI. सर्व हक्क राखीव.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.green[700]),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                color: Colors.green[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ServiceChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _ContactForm extends StatefulWidget {
  const _ContactForm({super.key});

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isNameValid = true;
  bool _isEmailValid = true;
  bool _isMessageValid = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  InputDecoration _getInputDecoration({
    required String label,
    required Icon icon,
    required bool isValid,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: isValid ? Colors.green : Colors.red),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: isValid ? Colors.grey : Colors.red),
      ),
      errorText: isValid ? null : 'कृपया वैध माहिती प्रविष्ट करा',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'तुमचे नाव',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      _nameController.text.isNotEmpty
                          ? Colors.grey
                          : const Color.fromARGB(255, 148, 145, 145),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      _nameController.text.isNotEmpty
                          ? Colors.green
                          : Color.fromARGB(255, 148, 145, 145),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator:
                (value) =>
                    value == null || value.trim().isEmpty
                        ? 'कृपया नाव प्रविष्ट करा'
                        : null,
            onChanged: (value) {
              setState(() {}); // Refreshes the widget when input changes
            },
          ),

          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.emailAddress,
            decoration: _getInputDecoration(
              label: 'ईमेल',
              icon: const Icon(Icons.email),
              isValid: _isEmailValid,
            ),
            onChanged: (value) {
              setState(() {
                _isEmailValid = value.contains('@');
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'कृपया ईमेल प्रविष्ट करा';
              }
              if (!value.contains('@')) {
                return 'वैध ईमेल प्रविष्ट करा';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),
          TextFormField(
            controller: _messageController,
            maxLines: 4,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              setState(() {
                _isMessageValid = value.isNotEmpty;
              });
            },
            decoration: _getInputDecoration(
              label: 'संदेश',
              icon: const Icon(Icons.message),
              isValid: _isMessageValid,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'कृपया संदेश प्रविष्ट करा';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('धन्यवाद! आपला संदेश पाठवला गेला आहे.'),
                  ),
                );
                _nameController.clear();
                _emailController.clear();
                _messageController.clear();
                setState(() {
                  _isNameValid = true;
                  _isEmailValid = true;
                  _isMessageValid = true;
                });
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('संदेश पाठवा'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
