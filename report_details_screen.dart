import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ebalagh_app/models/report_model.dart';
import 'package:ebalagh_app/services/storage_service.dart';

class ReportDetailsScreen extends StatefulWidget {
  final ReportModel report;

  const ReportDetailsScreen({
    super.key,
    required this.report,
  });

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final StorageService _storageService = StorageService();
  List<Map<String, dynamic>> _images = [];
  bool _isLoadingImages = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    List<Map<String, dynamic>> images = await _storageService.getReportImages(
      widget.report.id!,
    );
    setState(() {
      _images = images;
      _isLoadingImages = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل البلاغ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildInfoSection(),
            const SizedBox(height: 24),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildImagesSection(),
            const SizedBox(height: 24),
            _buildTimelineSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      // ignore: deprecated_member_use
      color: Color(widget.report.statusColor).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.report_problem,
              color: Color(widget.report.statusColor),
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بلاغ #${widget.report.id!.substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(widget.report.statusColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.report.statusArabic,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات البلاغ',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.title,
          label: 'العنوان',
          value: widget.report.title,
        ),
        _buildInfoRow(
          icon: Icons.description,
          label: 'الوصف',
          value: widget.report.description,
        ),
        _buildInfoRow(
          icon: Icons.calendar_today,
          label: 'تاريخ التقديم',
          value: _formatDateTime(widget.report.createdAt),
        ),
        if (widget.report.updatedAt != null)
          _buildInfoRow(
            icon: Icons.update,
            label: 'آخر تحديث',
            value: _formatDateTime(widget.report.updatedAt!),
          ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الموقع الجغرافي',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  widget.report.location.latitude,
                  widget.report.location.longitude,
                ),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ebalagh_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: LatLng(
                        widget.report.location.latitude,
                        widget.report.location.longitude,
                      ),
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.report.location.fullAddress,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الصور المرفقة (${_images.length})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (_isLoadingImages)
          const Center(child: CircularProgressIndicator())
        else if (_images.isEmpty)
          Center(
            child: Text(
              'لا توجد صور مرفقة',
              style: TextStyle(color: Colors.grey[500]),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showFullImage(_images[index]['imageUrl']);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(_images[index]['imageUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTimelineSection() {
    List<Map<String, dynamic>> timeline = [
      {
        'status': 'new',
        'title': 'تم استلام البلاغ',
        'date': widget.report.createdAt,
        'isCompleted': true,
      },
      {
        'status': 'processing',
        'title': 'قيد المعالجة',
        'date': widget.report.status == 'processing'
            ? widget.report.updatedAt
            : null,
        'isCompleted':
            ['processing', 'resolved', 'closed'].contains(widget.report.status),
      },
      {
        'status': 'resolved',
        'title': 'تم الحل',
        'date':
            widget.report.status == 'resolved' ? widget.report.updatedAt : null,
        'isCompleted': ['resolved', 'closed'].contains(widget.report.status),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سير المعالجة',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...timeline.map((item) => _buildTimelineItem(item)),
      ],
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item) {
    bool isCompleted = item['isCompleted'];
    bool isCurrent = item['status'] == widget.report.status;

    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : (isCurrent ? Colors.orange : Colors.grey[300]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                color: Colors.white,
                size: 16,
              ),
            ),
            if (item['status'] != 'resolved')
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'],
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (item['date'] != null)
                Text(
                  _formatDateTime(item['date']),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
