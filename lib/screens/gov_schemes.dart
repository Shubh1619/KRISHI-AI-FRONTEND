import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SchemesScreen extends StatefulWidget {
  @override
  _SchemesScreenState createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  Set<String> _selectedNeeds = {};
  bool _showAllSchemes = false;
  List<dynamic>? _recommendations;

  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _landSizeController = TextEditingController();
  final TextEditingController _needsController = TextEditingController();

  String? _selectedState;
  String? _selectedCrop;
  String? _selectedSoilType;
  String? _selectedFarmerCategory;

  final List<String> _states = [
    'महाराष्ट्र', 'पंजाब', 'हरियाणा', 'उत्तर प्रदेश',
    'गुजरात', 'राजस्थान', 'कर्नाटक', 'तमिळनाडू'
  ];
  final List<String> _crops = [
    'गहू', 'तांदूळ', 'टोमॅटो', 'कांदा', 'कापूस', 'ऊस', 'बटाटा', 'मका'
  ];
  final List<String> _soilTypes = [
    'चिकणमाती', 'वालुकामय', 'काळी माती', 'लाल माती', 'गार माती', 'पांढरी माती'
  ];
  final List<String> _farmerCategories = [
    'लहान', 'मध्यम', 'मोठे', 'इतर'
  ];
  final List<String> _needsChips = [
    'सिंचन', 'साठवणूक', 'यंत्रसामग्री', 'बियाणे', 'खते', 'कर्ज', 'विमा', 'प्रशिक्षण'
  ];

  Future<void> fetchAIRecommendations() async {
    final state = _selectedState;
    final district = _districtController.text.trim();
    final crop = _selectedCrop;
    final landSize = _landSizeController.text.trim();
    final soilType = _selectedSoilType;
    final category = _selectedFarmerCategory;
    final needs = _needsController.text.trim();

    if (state == null || crop == null || soilType == null || category == null || district.isEmpty || landSize.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('कृपया सर्व फील्ड भरा')),
      );
      return;
    }

    final uri = Uri.parse(
      'https://krushi-ai.onrender.com/schemes/gemini-recommend'
      '?user_state=$state'
      '&user_district=$district'
      '&user_crop=$crop'
      '&user_land_size=$landSize'
      '&user_soil_type=$soilType'
      '&user_category=$category'
      '&user_needs=${Uri.encodeComponent(needs)}',
    );

    try {
      final res = await http.get(uri, headers: {'accept': 'application/json'});
      if (res.statusCode == 200) {
        final jsonRes = jsonDecode(res.body);
        setState(() {
          _recommendations = jsonRes['schemes'];
        });
      } else {
        print('Failed: ${res.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget _buildRecommendationsCard() {
    if (_recommendations == null) {
      return Container();
    }

    if (_recommendations!.isEmpty) {
      return Center(child: Text('शिफारसी सापडल्या नाहीत'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _recommendations!.map((scheme) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Icon(Icons.account_balance_wallet_outlined, color: Colors.green),
            title: Text(scheme['name'] ?? 'नाव नसलेली योजना'),
            subtitle: Text(scheme['description'] ?? ''),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabButton(String title, bool selected) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Color(0xFFF5F5F5),
        border: Border.all(color: selected ? Colors.green : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
      ),
    );
  }

  Widget _buildAllSchemesView() {
    return Center(child: Text("सर्व योजनांचे दृश्य"));
  }

  Widget _buildAISchemeAdvisorView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedState,
          items: _states.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
          onChanged: (val) => setState(() => _selectedState = val),
          decoration: InputDecoration(labelText: 'राज्य'),
        ),
        TextField(
          controller: _districtController,
          decoration: InputDecoration(labelText: 'जिल्हा'),
        ),
        DropdownButtonFormField<String>(
          value: _selectedCrop,
          items: _crops.map((crop) => DropdownMenuItem(value: crop, child: Text(crop))).toList(),
          onChanged: (val) => setState(() => _selectedCrop = val),
          decoration: InputDecoration(labelText: 'पीक'),
        ),
        TextField(
          controller: _landSizeController,
          decoration: InputDecoration(labelText: 'जमिनीचे क्षेत्रफळ'),
        ),
        DropdownButtonFormField<String>(
          value: _selectedSoilType,
          items: _soilTypes.map((soil) => DropdownMenuItem(value: soil, child: Text(soil))).toList(),
          onChanged: (val) => setState(() => _selectedSoilType = val),
          decoration: InputDecoration(labelText: 'मातीचा प्रकार'),
        ),
        DropdownButtonFormField<String>(
          value: _selectedFarmerCategory,
          items: _farmerCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
          onChanged: (val) => setState(() => _selectedFarmerCategory = val),
          decoration: InputDecoration(labelText: 'शेतकऱ्याचा प्रकार'),
        ),
        TextField(
          controller: _needsController,
          decoration: InputDecoration(labelText: 'गरजा (स्वल्पविरामाने विभक्त)'),
        ),
        Wrap(
          spacing: 8,
          children: _needsChips.map((chip) {
            final selected = _selectedNeeds.contains(chip);
            return ChoiceChip(
              label: Text(chip),
              selected: selected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedNeeds.add(chip);
                  } else {
                    _selectedNeeds.remove(chip);
                  }
                  _needsController.text = _selectedNeeds.join(', ');
                });
              },
            );
          }).toList(),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: fetchAIRecommendations,
          child: Text('AI शिफारसी मिळवा'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('सरकारी योजना', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showAllSchemes = false),
                    child: _buildTabButton('AI योजना सल्लागार', !_showAllSchemes),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _showAllSchemes ? _buildAllSchemesView() : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAISchemeAdvisorView(),
                  SizedBox(height: 20),
                  _buildRecommendationsCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}