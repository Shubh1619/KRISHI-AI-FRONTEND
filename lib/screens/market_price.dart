import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MandiPricesScreen extends StatefulWidget {
  const MandiPricesScreen({super.key});

  @override
  State<MandiPricesScreen> createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends State<MandiPricesScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
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
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  @override
  bool get wantKeepAlive => false;

  Future<void> fetchLatestPrices() async {
    final crop = cropController.text.trim();
    final state = stateController.text.trim();

    if (crop.isEmpty || state.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया पिकाचे नाव आणि राज्य प्रविष्ट करा'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      latestData = null;
    });

    final url = Uri.parse(
      'http://3.110.37.119:8000/mandi/latest?crop=$crop&state=$state',
    );

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        setState(() {
          latestData = json.decode(res.body);
        });
      }
    } catch (_) {
      setState(() => latestData = null);
    }

    setState(() => isLoading = false);
  }

  Future<void> fetchHistoryPrices() async {
    final crop = cropController.text.trim();
    final district = districtController.text.trim();
    final days = daysController.text.trim();

    if (crop.isEmpty || district.isEmpty || days.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('कृपया सर्व फील्ड भरावेत')));
      return;
    }

    setState(() {
      isLoading = true;
      historyData = null;
    });

    final url = Uri.parse(
      'http://3.110.37.119:8000/mandi/history?crop=$crop&district=$district&days=$days',
    );

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final response = json.decode(res.body);
        List<dynamic>? dataList;
        if (response is List) {
          dataList = response;
        } else if (response is Map) {
          dataList = response['इतिहास'] is List ? response['इतिहास'] : [];
        } else {
          dataList = [];
        }
        setState(() {
          historyData = dataList;
        });
      }
    } catch (e) {
      setState(() => historyData = null);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text('🧾 बाजारभाव माहिती'),
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
          if (latestData != null && latestData!.isNotEmpty) ...[
            const Text(
              '⏬ मिळालेली माहिती:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoCard('📦 पीक', latestData!['पीक'] ?? 'माहिती नाही'),
            _buildInfoCard('🏞️ राज्य', latestData!['राज्य'] ?? 'माहिती नाही'),
            _buildInfoCard(
              '💰 किंमत',
              '₹${latestData!['नवीनतम किंमत'] ?? '--'}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
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
          const SizedBox(height: 20),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (historyData != null && historyData!.isNotEmpty) ...[
            const Text(
              '⏬ मागील दर माहिती:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: historyData!.length,
              itemBuilder: (context, index) {
                final item = historyData![index];
                return Card(
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
                    title: Text(
                      '📅 दिनांक: ${item['दिनांक'] ?? 'माहिती नाही'}',
                    ),
                    subtitle: Text('💵 दर: ₹${item['किंमत'] ?? 'माहिती नाही'}'),
                  ),
                );
              },
            ),
          ] else if (historyData != null && historyData!.isEmpty)
            const Text('डेटा उपलब्ध नाही', style: TextStyle(color: Colors.red)),
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
