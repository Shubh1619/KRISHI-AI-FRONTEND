import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';

class FertilizerScreen extends StatefulWidget {
  const FertilizerScreen({super.key});

  @override
  State<FertilizerScreen> createState() => _FertilizerScreenState();
}

class _FertilizerScreenState extends State<FertilizerScreen> {
  final cropController = TextEditingController();

  String? selectedSoilType;
  String? selectedStage;

  List<dynamic> recommendations = [];
  String? generalNotes;
  bool isLoading = false;

  final List<String> soilTypes = [
    'गाळमाती',
    'काळी माती',
    'तांबडी माती',
    'लेटराइट माती',
    'वाळवंटी माती',
    'डोंगराळ माती',
    'दुपद / दलदली माती',
    'खारट व अल्कधर्मी माती',
  ];

  final List<String> cropStages = [
    'बीजप्रक्रिया',
    'पेरणी',
    'अंकुरण',
    'प्राथमिक वाढ',
    'मुख्य वाढीचा टप्पा',
    'फुलोरा',
    'फळधारणा',
    'परिपक्वता',
    'कापणी',
    'शेती व्यवस्थापन',
  ];

  Future<void> fetchFertilizerRecommendation() async {
    final crop = cropController.text.trim();
    final soil = selectedSoilType;
    final stage = selectedStage;

    if (crop.isEmpty || soil == null || stage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('कृपया सर्व माहिती भरा')));
      return;
    }

    setState(() {
      isLoading = true;
      recommendations = [];
      generalNotes = null;
    });

    final url = Uri.parse(
      'http://3.110.37.119:8000/recommend-fertilizer?crop=$crop&soil_type=$soil&stage=$stage',
    );

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recommendations = data['recommendations'] ?? [];
          generalNotes = data['general_notes'] ?? 'सामान्य सूचना उपलब्ध नाहीत';
        });
      } else {
        setState(() {
          recommendations = [];
          generalNotes = 'सर्व्हर त्रुटी: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        recommendations = [];
        generalNotes = 'API कॉल करताना त्रुटी आली';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    cropController.dispose();
    super.dispose();
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: true,
        fillColor: Colors.white,
      ),
      value: selectedValue,
      onChanged: onChanged,
      items:
          items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      buttonStyleData: const ButtonStyleData(height: 55),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.green.shade300),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text('💡 खत सल्ला'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputField(cropController, 'पिकाचे नाव'),
            const SizedBox(height: 10),
            _buildDropdown('मातीचा प्रकार', soilTypes, selectedSoilType, (val) {
              setState(() => selectedSoilType = val);
            }),
            const SizedBox(height: 10),
            _buildDropdown('पीक टप्पा', cropStages, selectedStage, (val) {
              setState(() => selectedStage = val);
            }),
            const SizedBox(height: 20),
            _buildButton('🔍 सल्ला मिळवा', fetchFertilizerRecommendation),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else ...[
              if (recommendations.isNotEmpty)
                ...recommendations
                    .map((item) => _buildFertilizerCard(item))
                    .toList(),
              if (generalNotes != null)
                _buildResultCard("📝 सामान्य सूचना:\n$generalNotes"),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFertilizerCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "खत: ${item['fertilizer']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text("प्रमाण (प्रती एकर): ${item['quantity_per_acre_kg']} किलो"),
            const SizedBox(height: 4),
            Text("कसा वापरायचा: ${item['application_tip']}"),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String message) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.green),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.search),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
