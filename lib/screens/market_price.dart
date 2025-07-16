import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MandiPricesScreen extends StatefulWidget {
  @override
  _MandiPricesScreenState createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends State<MandiPricesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final cropController = TextEditingController();
  final daysController = TextEditingController();
  final stateController = TextEditingController();
  final districtController = TextEditingController();

  Map<String, dynamic>? latestData;
  List<dynamic>? historyData;
  bool isLoading = false;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    cropController.dispose();
    daysController.dispose();
    stateController.dispose();
    districtController.dispose();
    super.dispose();
  }

  Future<void> fetchLatestPrices() async {
    setState(() => isLoading = true);
    final crop = cropController.text.trim();
    final state = stateController.text.trim();
    final url = Uri.parse(
      'https://krushi-ai.onrender.com/mandi/latest?crop=$crop&state=$state',
    );
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        setState(() {
          latestData = json.decode(res.body);
        });
      } else {
        setState(() {
          latestData = null;
        });
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> fetchHistoryPrices() async {
    setState(() => isLoading = true);
    final crop = cropController.text.trim();
    final district = districtController.text.trim();
    final days = daysController.text.trim();
    final url = Uri.parse(
      'https://krushi-ai.onrender.com/mandi/history?crop=$crop&district=$district&days=$days',
    );
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final response = json.decode(res.body);
        setState(() {
          historyData = response['history'];
        });
      } else {
        setState(() {
          historyData = null;
        });
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text('🧾 मंडी दर माहिती'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: '🔍 नवीन दर'), Tab(text: '📈 दर इतिहास')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildLatestTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildLatestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(cropController, 'पिकाचे नाव'),
          const SizedBox(height: 10),
          _buildInputField(stateController, 'राज्य'),
          const SizedBox(height: 16),
          _buildButton('🔎 शोधा', fetchLatestPrices),
          const SizedBox(height: 20),
          if (isLoading) const Center(child: CircularProgressIndicator()),
          if (latestData != null) ...[
            _buildInfoCard('📦 पीक', latestData!['पीक'] ?? '--'),
            _buildInfoCard('🏞️ राज्य', latestData!['राज्य'] ?? '--'),
            _buildInfoCard('💰 किंमत', '₹${latestData!['नवीनतम किंमत']}'),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInputField(cropController, 'पिक'),
          const SizedBox(height: 10),
          _buildInputField(districtController, 'जिल्हा'),
          const SizedBox(height: 10),
          _buildInputField(
            daysController,
            'दिवस',
            inputType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildButton('📊 इतिहास पाहा', fetchHistoryPrices),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
          if (historyData != null)
            Expanded(
              child: ListView.builder(
                itemCount: historyData!.length,
                itemBuilder: (context, index) {
                  final item = historyData![index];
                  return Card(
                    color: Colors.white,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.calendar_month,
                        color: Colors.green,
                      ),
                      title: Text('📅 दिनांक: ${item['दिनांक']}'),
                      subtitle: Text('💵 दर: ₹${item['किंमत']}'),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label, {
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.search),
        label: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.info, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
