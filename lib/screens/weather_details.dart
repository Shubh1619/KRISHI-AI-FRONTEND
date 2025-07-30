import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';

class WeatherDetailsPage extends StatefulWidget {
  const WeatherDetailsPage({super.key});

  @override
  State<WeatherDetailsPage> createState() => _WeatherDetailsPageState();
}

class _WeatherDetailsPageState extends State<WeatherDetailsPage> {
  final TextEditingController _cityController = TextEditingController();

  final List<String> stages = [
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

  final List<String> crops = ["गहू",
    "तांदूळ (भात)",
    "मका",
    "जव (बार्ली)",
    "ज्वारी",
    "बाजरी",
    "नाचणी (रागी)",
    "ओट्स",
    "हरभरा (चना)",
    "तूर (अरहर)",
    "मूग",
    "उडीद",
    "मसूर",
    "मटार",
    "सोयाबीन",
    "शेंगदाणा",
    "मोहरी",
    "सूर्यफूल",
    "तीळ",
    "एरंडी",
    "आंबा",
    "केळं",
    "सफरचंद",
    "द्राक्षे",
    "पेरू",
    "संत्रं",
    "पपई",
    "डाळिंब",
    "टोमॅटो",
    "बटाटा",
    "कांदा",
    "वांगी",
    "कोबी",
    "फुलकोबी",
    "भेंडी",
    "पालक",
    "कापूस",
    "ऊस",
    "तंबाखू",
    "चहा",
    "कॉफी",
    "नारळ",
    "रबर",
    "हळद",
    "आले",
    "लसूण",
    "मिरची",
    "धणे",
    "वेलदोडा",
    "काळी मिरी",
    ];

  String? selectedStage;
  String? selectedCrop;
  Map<String, dynamic>? weatherData;
  Map<String, dynamic>? advisoryData;
  bool _loading = false;
  String? _error;

  Future<void> _fetchWeatherOnly() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      setState(() => _error = 'कृपया शहराचे नाव भरा.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      weatherData = null;
    });

    try {
      final response = await http.get(
        // Uri.parse('https://krushi-ai.onrender.com/weather/current?city=$city'),
        Uri.parse('http://3.110.37.119:8000/weather/current?city=$city'),
      );
      if (response.statusCode == 200) {
        setState(() => weatherData = jsonDecode(response.body));
      } else {
        setState(() => _error = 'हवामान मिळवण्यात अयशस्वी.');
      }
    } catch (e) {
      setState(() => _error = 'त्रुटी: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchAdvisoryOnly() async {
    final city = _cityController.text.trim();
    if (city.isEmpty || selectedCrop == null || selectedStage == null) {
      setState(() => _error = 'कृपया सर्व माहिती भरा (शहर, पीक, टप्पा).');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      advisoryData = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          // 'https://krushi-ai.onrender.com/weather/advisory?crop=$selectedCrop&stage=$selectedStage&city=$city',
          'http://3.110.37.119:8000/weather/advisory?crop=$selectedCrop&stage=$selectedStage&city=$city',
        ),
      );
      if (response.statusCode == 200) {
        setState(() => advisoryData = jsonDecode(response.body));
      } else {
        setState(() => _error = 'सल्ला मिळवण्यात अयशस्वी.');
      }
    } catch (e) {
      setState(() => _error = 'त्रुटी: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildWeatherCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('हवामान आणि सल्ला'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _loading, // 👈 disables all UI interaction when true
            child: Opacity(
              opacity: _loading ? 0.5 : 1.0, // 👈 dims UI during loading
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'शहर',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('शहराचे नाव लिहा'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: false,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _fetchWeatherOnly,
                      icon: const Icon(Icons.cloud, color: Colors.white),
                      label: const Text(
                        'हवामान मिळवा',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_loading)
                      const Center(child: CircularProgressIndicator()),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    if (weatherData != null) ...[
                      const Text(
                        'सद्य हवामान',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildWeatherCard(
                            'तापमान',
                            '${weatherData!['तापमान (°C)']}°C',
                            Colors.blue,
                            Icons.thermostat,
                          ),
                          const SizedBox(width: 10),
                          _buildWeatherCard(
                            'आर्द्रता',
                            '${weatherData!['आर्द्रता']}%',
                            Colors.green,
                            Icons.water_drop,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildWeatherCard(
                            'दृष्यता',
                            weatherData!['दृष्यता'] ?? 'N/A',
                            Colors.orange,
                            Icons.remove_red_eye,
                          ),
                          const SizedBox(width: 10),
                          _buildWeatherCard(
                            'वारा',
                            weatherData!['वारा'] ?? 'N/A',
                            Colors.purple,
                            Icons.air,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (weatherData!['वर्णन'] != null)
                        Text(
                          '🌤️ वर्णन: ${weatherData!['वर्णन']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],

                    const SizedBox(height: 30),
                    const Text(
                      'पिक हवामान सल्ला',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('तुमच्या पिकासाठी हवामान सल्ला मिळवा'),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedCrop,
                      decoration: InputDecoration(
                        labelText: 'पीक निवडा',
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.green,
                            width: 1.5,
                          ),
                        ),
                        isDense: true,
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 32, // Bigger arrow
                        color: Colors.black54,
                      ),
                      dropdownColor: Colors.white,
                      items:
                          crops.map((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() => selectedCrop = value),
                      selectedItemBuilder:
                          (context) =>
                              crops
                                  .map(
                                    (item) => Text(
                                      item,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  )
                                  .toList(),
                      menuMaxHeight: 200,
                      // Gray scrollbar workaround: see crop_disease_detection.dart for advanced control
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: selectedStage,
                      decoration: InputDecoration(
                        labelText: 'टप्पा निवडा',
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.green,
                            width: 1.5,
                          ),
                        ),
                        isDense: true,
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 32, // Bigger arrow
                        color: Colors.black54,
                      ),
                      dropdownColor: Colors.white,
                      items:
                          stages.map((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() => selectedStage = value),
                      selectedItemBuilder:
                          (context) =>
                              stages
                                  .map(
                                    (item) => Text(
                                      item,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  )
                                  .toList(),
                      menuMaxHeight: 200,
                      // Gray scrollbar workaround: see crop_disease_detection.dart for advanced control
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: _fetchAdvisoryOnly,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'सल्ला मिळवा',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 20),
                    if (advisoryData != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'हवामान सल्ला',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            advisoryData!['सल्ला']?.join('\n') ??
                                'सल्ला उपलब्ध नाही.',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),

          // 🔄 Centered loader only when _loading is true
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
