import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CropDiseaseDetectionPage extends StatefulWidget {
  const CropDiseaseDetectionPage({super.key});

  @override
  State<CropDiseaseDetectionPage> createState() =>
      _CropDiseaseDetectionPageState();
}

class _CropDiseaseDetectionPageState extends State<CropDiseaseDetectionPage> {
  Uint8List? _imageBytes;
  String? _selectedCrop;
  String _selectedLang = 'mr';
  bool _loading = false;
  String? _diagnosisResult;

  final Map<String, String> _cache = {};
  final ImagePicker _picker = ImagePicker();

  final List<String> crops = [
    "गहू",
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

  final List<Map<String, String>> languages = [
    {'label': 'मराठी', 'code': 'mr'},
  ];

  Future<void> _pickImageFromGallery() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _diagnosisResult = null;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _diagnosisResult = null;
      });
    }
  }

  String _getImageHash(Uint8List bytes) {
    return bytes.sublist(0, 20).fold('', (s, b) => s + b.toString());
  }

  Future<void> _analyzeDisease() async {
    if (_selectedCrop == null || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया पीक निवडा आणि प्रतिमा अपलोड करा')),
      );
      return;
    }

    final hashKey = "${_selectedCrop}_${_getImageHash(_imageBytes!)}";
    if (_cache.containsKey(hashKey)) {
      setState(() => _diagnosisResult = _cache[hashKey]);
      return;
    }

    setState(() {
      _loading = true;
      _diagnosisResult = null;
    });

    try {
      final dio = Dio(
        BaseOptions(
          // baseUrl: 'https://krushi-ai.onrender.com',
          baseUrl: 'http://3.110.37.119:8000',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

      final fileName = "image.jpg";
      final formData = FormData.fromMap({
        'crop': _selectedCrop,
        'lang': _selectedLang,
        'image': MultipartFile.fromBytes(
          _imageBytes!,
          filename: fileName,
          contentType: MediaType("image", "jpeg"),
        ),
      });

      final response = await dio.post("/crop/diagnose", data: formData);

      dynamic resultRaw = response.data['result'];
      String resultFormatted;

      if (resultRaw is String) {
        final lines = resultRaw.split('\n');

        // Try extracting bullet points
        final bulletPoints =
            lines
                .where(
                  (line) =>
                      line.trim().startsWith(RegExp(r'[-•●]')) ||
                      line.contains('▪'),
                )
                .take(5)
                .toList();

        // ✅ If bullet points exist, join them, otherwise fallback to raw string
        if (bulletPoints.isEmpty) {
          resultFormatted = resultRaw;
        } else {
          resultFormatted = bulletPoints.join('\n');
        }
      } else if (resultRaw is Map<String, dynamic>) {
        resultFormatted = '''
**🔍 रोग:** ${resultRaw['disease'] ?? 'माहिती नाही'}
**💊 उपाय:** ${resultRaw['recommendation'] ?? 'माहिती नाही'}
''';
      } else {
        resultFormatted = resultRaw?.toString() ?? '';
      }

      // ❌ Remove note section if present
      resultFormatted =
          resultFormatted
              .replaceAll(RegExp(r'नोंद:.*$', dotAll: true), '')
              .trim();

      setState(() {
        _diagnosisResult =
            resultFormatted.isEmpty
                ? '⚠️ निदान झाले पण कोणतीही माहिती मिळाली नाही.'
                : resultFormatted;
        _cache[hashKey] = _diagnosisResult!;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ त्रुटी: ${e.toString()}')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('पिक रोग निदान'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _loading, // 👈 disables interaction when true
            child: Opacity(
              opacity: _loading ? 0.5 : 1.0, // 👈 fades UI when loading
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'पिकाची प्रतिमा अपलोड करा',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'पान किंवा पिकाची स्पष्ट प्रतिमा घ्या',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          value: _selectedCrop,
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
                              (value) => setState(() => _selectedCrop = value),
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
                          // Wrap the dropdown menu with a gray scrollbar
                          // This is a workaround for gray scrollbar in DropdownButtonFormField
                          // For more advanced control, use dropdown_button2 as in your previous code
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _selectedLang,
                          decoration: const InputDecoration(
                            labelText: 'भाषा निवडा',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              languages
                                  .map(
                                    (lang) => DropdownMenuItem(
                                      value: lang['code'],
                                      child: Text(lang['label']!),
                                    ),
                                  )
                                  .toList(),
                          onChanged: null, // 🔒 Disables the dropdown
                        ),

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: _pickImageFromGallery,
                          child: Container(
                            width: 250,
                            height: 250,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey),
                            ),
                            child:
                                _imageBytes == null
                                    ? const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text('प्रतिमा निवडा'),
                                      ],
                                    )
                                    : ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.memory(
                                        _imageBytes!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        ElevatedButton.icon(
                          onPressed: _pickImageFromGallery,
                          icon: const Icon(Icons.upload_file),
                          label: const Text("गॅलरीमधून निवडा"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          onPressed: _pickImageFromCamera,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("कॅमेरा वापरा"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          onPressed: _loading ? null : _analyzeDisease,
                          icon: const Icon(Icons.search),
                          label:
                              _loading
                                  ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text("रोग विश्लेषण करा"),
                        ),
                        const SizedBox(height: 24),

                        if (_diagnosisResult != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: MarkdownBody(
                              data: _diagnosisResult!,
                              styleSheet: MarkdownStyleSheet.fromTheme(
                                Theme.of(context),
                              ).copyWith(
                                p: const TextStyle(fontSize: 16),
                                h1: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                h2: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                listBullet: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(), // ✅ show loader
            ),
        ],
      ),
    );
  }
}
