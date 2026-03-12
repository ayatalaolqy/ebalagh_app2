import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:ebalagh_app/models/report_model.dart';
import 'package:ebalagh_app/models/department_model.dart';
import 'package:ebalagh_app/services/auth_service.dart';
import 'package:ebalagh_app/services/report_service.dart';
import 'package:ebalagh_app/services/storage_service.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ReportService _reportService = ReportService();
  final StorageService _storageService = StorageService();

  DepartmentModel? _selectedDepartment;
  List<DepartmentModel> _departments = [];
  // ignore: prefer_final_fields
  List<File> _selectedImages = [];

  LatLng? _currentLocation;
  final MapController _mapController = MapController();

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
    _getCurrentLocation();
  }

  Future<void> _fetchDepartments() async {
    setState(() {
      _departments = [
        DepartmentModel(
          name: 'كهرباء',
          serviceType: 'electricity',
          contactInfo: ContactInfo(phone: '123'),
        ),
        DepartmentModel(
          name: 'مياه',
          serviceType: 'water',
          contactInfo: ContactInfo(phone: '456'),
        ),
        DepartmentModel(
          name: 'بلدية - نظافة',
          serviceType: 'cleaning',
          contactInfo: ContactInfo(phone: '789'),
        ),
        DepartmentModel(
          name: 'طرق وجسور',
          serviceType: 'roads',
          contactInfo: ContactInfo(phone: '000'),
        ),
      ];
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقديم بلاغ جديد'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDepartmentDropdown(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'عنوان البلاغ',
                        hintText: 'مثال: انقطاع الكهرباء',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال عنوان البلاغ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'وصف البلاغ',
                        hintText: 'اشرح المشكلة بالتفصيل...',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال وصف البلاغ';
                        }
                        if (value.length < 10) {
                          return 'الوصف قصير جداً';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildImageSection(),
                    const SizedBox(height: 24),
                    _buildLocationSection(),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _submitReport,
                      icon: const Icon(Icons.send),
                      label: const Text(
                        'إرسال البلاغ',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<DepartmentModel>(
      value: _selectedDepartment,
      decoration: InputDecoration(
        labelText: 'الجهة المختصة',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: _departments.map((dept) {
        return DropdownMenuItem(
          value: dept,
          child: Text(dept.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDepartment = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'الرجاء اختيار الجهة المختصة';
        }
        return null;
      },
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الصور المرفقة (${_selectedImages.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_selectedImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImages.removeAt(index);
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(fromCamera: true),
                icon: const Icon(Icons.camera_alt),
                label: const Text('كاميرا'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(fromCamera: false),
                icon: const Icon(Icons.photo_library),
                label: const Text('المعرض'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الموقع الجغرافي',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _currentLocation != null
                ? FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation!,
                      initialZoom: 15.0,
                      onTap: (tapPosition, latLng) {
                        setState(() {
                          _currentLocation = latLng;
                        });
                      },
                    ),
                    children: [
                      //  طبقة OpenStreetMap
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.ebalagh_app',
                      ),
                      //  علامة الموقع
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40,
                            height: 40,
                            point: _currentLocation!,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const Center(
                    child: Text('جاري تحديد الموقع...'),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'انقر على الخريطة لتحديد موقع دقيق',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        if (_currentLocation != null)
          Text(
            'الإحداثيات: ${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    File? image = await _storageService.pickImage(fromCamera: fromCamera);
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentLocation == null) {
      setState(() {
        _error = 'الرجاء تحديد الموقع على الخريطة';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser!.id!;

      ReportModel report = ReportModel(
        userId: userId,
        departmentId: _selectedDepartment!.id ?? 'temp_id',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: ReportLocation(
          latitude: _currentLocation!.latitude,
          longitude: _currentLocation!.longitude,
          city: 'عتق',
          district: 'الوسط',
        ),
        createdAt: DateTime.now(),
      );

      String? reportId = await _reportService.createReport(report);

      if (reportId == null) {
        throw Exception('فشل إنشاء البلاغ');
      }

      for (File image in _selectedImages) {
        await _storageService.uploadReportImage(
          imageFile: image,
          reportId: reportId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال البلاغ بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _mapController.dispose();
    super.dispose();
  }
}
