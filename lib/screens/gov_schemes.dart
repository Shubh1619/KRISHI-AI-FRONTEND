import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';

class SchemesScreen extends StatefulWidget {
  @override
  _SchemesScreenState createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  Set<String> _selectedNeeds = {};
  bool _showAllSchemes = false;
  List<dynamic>? _recommendations;
  bool _loading = false;

  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _landSizeController = TextEditingController();
  final TextEditingController _needsController = TextEditingController();

  String? _selectedState;
  String? _selectedCrop;
  String? _selectedSoilType;
  String? _selectedFarmerCategory;

  final List<String> _states = [
    'महाराष्ट्र',
    'पंजाब',
    'हरियाणा',
    'उत्तर प्रदेश',
    'गुजरात',
    'राजस्थान',
    'कर्नाटक',
    'तमिळनाडू',
  ];
  final List<String> _crops = [
    'गहू',
    'तांदूळ',
    'टोमॅटो',
    'कांदा',
    'कापूस',
    'ऊस',
    'बटाटा',
    'मका',
  ];
  final List<String> _soilTypes = [
    'चिकणमाती',
    'वालुकामय',
    'काळी माती',
    'लाल माती',
    'गार माती',
    'पांढरी माती',
  ];
  final List<String> _farmerCategories = ['लहान', 'मध्यम', 'मोठे', 'इतर'];
  final List<String> _needsChips = [
    'सिंचन',
    'साठवणूक',
    'यंत्रसामग्री',
    'बियाणे',
    'खते',
    'कर्ज',
    'विमा',
    'प्रशिक्षण',
  ];

  Future<void> fetchAIRecommendations() async {
    final state = _selectedState;
    final district = _districtController.text.trim();
    final crop = _selectedCrop;
    final landSize = _landSizeController.text.trim();
    final soilType = _selectedSoilType;
    final category = _selectedFarmerCategory;
    final needs = _needsController.text.trim();

    if (state == null ||
        crop == null ||
        soilType == null ||
        category == null ||
        district.isEmpty ||
        landSize.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('कृपया सर्व फील्ड भरा')));
      return;
    }

    setState(() => _loading = true);

    final uri = Uri.parse(
      // 'https://krushi-ai.onrender.com/schemes/gemini-recommend'
       'http://13.234.76.137:8000/schemes/gemini-recommend'
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
        setState(() => _recommendations = jsonRes['schemes']);
      } else {
        print('Failed: ${res.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selected,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      value: selected,
      onChanged: _loading ? null : onChanged,
      items:
          items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
      buttonStyleData: ButtonStyleData(height: 55),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.green.shade300),
          trackColor: MaterialStateProperty.all(Colors.grey[300]),
          radius: Radius.circular(8),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  Widget _buildAISchemeAdvisorView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          'राज्य',
          _states,
          _selectedState,
          (val) => setState(() => _selectedState = val),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _districtController,
          decoration: InputDecoration(
            labelText: 'जिल्हा',
            border: OutlineInputBorder(),
          ),
          enabled: !_loading,
        ),
        SizedBox(height: 10),
        _buildDropdown(
          'पीक',
          _crops,
          _selectedCrop,
          (val) => setState(() => _selectedCrop = val),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _landSizeController,
          decoration: InputDecoration(
            labelText: 'जमिनीचे क्षेत्रफळ',
            border: OutlineInputBorder(),
          ),
          enabled: !_loading,
        ),
        SizedBox(height: 10),
        _buildDropdown(
          'मातीचा प्रकार',
          _soilTypes,
          _selectedSoilType,
          (val) => setState(() => _selectedSoilType = val),
        ),
        SizedBox(height: 10),
        _buildDropdown(
          'शेतकऱ्याचा प्रकार',
          _farmerCategories,
          _selectedFarmerCategory,
          (val) => setState(() => _selectedFarmerCategory = val),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _needsController,
          decoration: InputDecoration(
            labelText: 'गरजा (स्वल्पविरामाने विभक्त)',
            border: OutlineInputBorder(),
          ),
          enabled: !_loading,
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children:
              _needsChips.map((chip) {
                final selected = _selectedNeeds.contains(chip);
                return ChoiceChip(
                  label: Text(chip),
                  selected: selected,
                  onSelected:
                      _loading
                          ? null
                          : (bool selected) {
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
          onPressed: _loading ? null : fetchAIRecommendations,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child:
              _loading
                  ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Text(
                    'AI शिफारसी मिळवा',
                    style: TextStyle(color: Colors.white),
                  ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard() {
    if (_recommendations == null) return Container();
    if (_recommendations!.isEmpty) {
      return Center(child: Text('शिफारसी सापडल्या नाहीत'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          _recommendations!.map((scheme) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.green,
                ),
                title: Text(scheme['name'] ?? 'नाव नसलेली योजना'),
                subtitle: Text(scheme['description'] ?? ''),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showAllSchemes = false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showAllSchemes ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'AI योजना सल्लागार',
                  style: TextStyle(
                    color: !_showAllSchemes ? Colors.white : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _loading,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'सरकारी योजना',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                SizedBox(height: 16),
                _buildTabBar(),
                SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _showAllSchemes
                            ? Center(child: Text("सर्व योजनांचे दृश्य"))
                            : _buildAISchemeAdvisorView(),
                        SizedBox(height: 20),
                        _buildRecommendationsCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_loading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
