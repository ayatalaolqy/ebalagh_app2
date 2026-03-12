import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebalagh_app/models/report_model.dart';
import 'package:ebalagh_app/services/auth_service.dart';
import 'package:ebalagh_app/services/report_service.dart';
import '../citizen/report_details_screen.dart';

/// لوحة تحكم الموظف (الجهة الخدمية)
class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final reportService = ReportService();
    String departmentId = 'temp_dept_id';

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الموظف'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(context),
          Expanded(
            child: StreamBuilder<List<ReportModel>>(
              stream: reportService.getDepartmentReports(departmentId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('لا توجد بلاغات جديدة'),
                  );
                }

                List<ReportModel> reports = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    ReportModel report = reports[index];
                    return _buildReportCard(context, report);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('جديدة', '3', Colors.orange),
          _buildSummaryItem('قيد المعالجة', '5', Colors.blue),
          _buildSummaryItem('تم الحل', '12', Colors.green),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(BuildContext context, ReportModel report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          report.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(report.description, maxLines: 2),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.location.fullAddress,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: _buildStatusDropdown(report),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportDetailsScreen(report: report),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusDropdown(ReportModel report) {
    return DropdownButton<String>(
      value: report.status,
      underline: const SizedBox(),
      icon: const Icon(Icons.more_vert),
      items: ['new', 'processing', 'resolved', 'closed'].map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(_getStatusText(status)),
        );
      }).toList(),
      onChanged: (newStatus) {
        _updateReportStatus(report.id!, newStatus!);
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'new':
        return 'جديد';
      case 'processing':
        return 'قيد المعالجة';
      case 'resolved':
        return 'تم الحل';
      case 'closed':
        return 'مغلق';
      default:
        return status;
    }
  }

  Future<void> _updateReportStatus(String reportId, String newStatus) async {
    // TODO: تنفيذ التحديث
  }
}
