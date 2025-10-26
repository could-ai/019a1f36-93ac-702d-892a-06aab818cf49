import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image/image.dart' as img;

class PhotoEditorScreen extends StatefulWidget {
  const PhotoEditorScreen({super.key});

  @override
  State<PhotoEditorScreen> createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends State<PhotoEditorScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  
  // Image editing parameters
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  Color _selectedColor = Colors.white;
  bool _isBlackWhite = false;
  bool _isSepia = false;
  bool _isVintage = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Editor'),
        backgroundColor: const Color(0xFF1a1a1a),
        actions: [
          if (_image != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveImage,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey[900]!,
              Colors.black,
            ],
          ),
        ),
        child: Column(
          children: [
            // Image Display Area
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _image == null
                    ? _buildImagePlaceholder()
                    : _buildImageDisplay(),
              ),
            ),
            
            // Control Panel
            if (_image != null)
              Expanded(
                flex: 2,
                child: _buildControlPanel(),
              ),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    'Gallery',
                    Icons.photo_library,
                    () => _pickImage(ImageSource.gallery),
                  ),
                  _buildActionButton(
                    'Camera',
                    Icons.camera_alt,
                    () => _pickImage(ImageSource.camera),
                  ),
                  if (_image != null)
                    _buildActionButton(
                      'Reset',
                      Icons.refresh,
                      _resetFilters,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Pilih foto untuk diedit',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageDisplay() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(_getColorMatrix()),
        child: Image.file(
          _image!,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
  
  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Filter Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton('B&W', _isBlackWhite, () {
                  setState(() {
                    _isBlackWhite = !_isBlackWhite;
                    if (_isBlackWhite) {
                      _isSepia = false;
                      _isVintage = false;
                    }
                  });
                }),
                _buildFilterButton('Sepia', _isSepia, () {
                  setState(() {
                    _isSepia = !_isSepia;
                    if (_isSepia) {
                      _isBlackWhite = false;
                      _isVintage = false;
                    }
                  });
                }),
                _buildFilterButton('Vintage', _isVintage, () {
                  setState(() {
                    _isVintage = !_isVintage;
                    if (_isVintage) {
                      _isBlackWhite = false;
                      _isSepia = false;
                    }
                  });
                }),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Brightness Control
            _buildSlider(
              'Brightness',
              _brightness,
              -1.0,
              1.0,
              (value) => setState(() => _brightness = value),
            ),
            
            // Contrast Control
            _buildSlider(
              'Contrast',
              _contrast,
              0.0,
              2.0,
              (value) => setState(() => _contrast = value),
            ),
            
            // Saturation Control
            _buildSlider(
              'Saturation',
              _saturation,
              0.0,
              2.0,
              (value) => setState(() => _saturation = value),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: Colors.amber,
          inactiveColor: Colors.white24,
          onChanged: onChanged,
        ),
      ],
    );
  }
  
  Widget _buildFilterButton(String label, bool isActive, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.amber : Colors.white24,
        foregroundColor: isActive ? Colors.black : Colors.white,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          onPressed: onPressed,
          child: Icon(icon, color: Colors.black, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _image = File(image.path);
          _resetFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }
  
  void _resetFilters() {
    setState(() {
      _brightness = 0.0;
      _contrast = 1.0;
      _saturation = 1.0;
      _isBlackWhite = false;
      _isSepia = false;
      _isVintage = false;
    });
  }
  
  List<double> _getColorMatrix() {
    List<double> matrix = [
      1, 0, 0, 0, _brightness * 255,
      0, 1, 0, 0, _brightness * 255,
      0, 0, 1, 0, _brightness * 255,
      0, 0, 0, 1, 0,
    ];
    
    // Apply contrast
    for (int i = 0; i < 3; i++) {
      matrix[i * 5 + i] = _contrast;
    }
    
    // Apply saturation
    if (_saturation != 1.0) {
      double s = _saturation;
      double sr = (1 - s) * 0.3086;
      double sg = (1 - s) * 0.6094;
      double sb = (1 - s) * 0.0820;
      
      matrix[0] = sr + s; matrix[1] = sg; matrix[2] = sb;
      matrix[5] = sr; matrix[6] = sg + s; matrix[7] = sb;
      matrix[10] = sr; matrix[11] = sg; matrix[12] = sb + s;
    }
    
    // Apply filters
    if (_isBlackWhite) {
      matrix = [
        0.299, 0.587, 0.114, 0, _brightness * 255,
        0.299, 0.587, 0.114, 0, _brightness * 255,
        0.299, 0.587, 0.114, 0, _brightness * 255,
        0, 0, 0, 1, 0,
      ];
    } else if (_isSepia) {
      matrix = [
        0.393, 0.769, 0.189, 0, _brightness * 255,
        0.349, 0.686, 0.168, 0, _brightness * 255,
        0.272, 0.534, 0.131, 0, _brightness * 255,
        0, 0, 0, 1, 0,
      ];
    } else if (_isVintage) {
      matrix = [
        0.6, 0.3, 0.1, 0, _brightness * 255 + 30,
        0.2, 0.7, 0.1, 0, _brightness * 255 + 20,
        0.2, 0.1, 0.7, 0, _brightness * 255 + 10,
        0, 0, 0, 1, 0,
      ];
    }
    
    return matrix;
  }
  
  Future<void> _saveImage() async {
    if (_image == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur save akan diimplementasikan dengan penyimpanan yang proper'),
        backgroundColor: Colors.green,
      ),
    );
  }
}