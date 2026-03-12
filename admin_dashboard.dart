import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebalagh_app/services/auth_service.dart';
import 'package:ebalagh_app/services/report_service.dart';

/// لوحة تحكم الإدارة المحلية
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final reportService = ReportService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, int>>(
              future: reportService.getReportStatistics(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                Map<String, int> stats = snapshot.data!;
                return _buildStatisticsGrid(stats);
              },
            ),
            const SizedBox(height: 24),
            Text(
              'إدارة النظام',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildManagementMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(Map<String, int> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'إجمالي البلاغات',
          stats['total']?.toString() ?? '0',
          Icons.assessment,
          Colors.blue,
        ),
        _buildStatCard(
          'جديدة',
          stats['new']?.toString() ?? '0',
          Icons.new_releases,
          Colors.orange,
        ),
        _buildStatCard(
          'قيد المعالجة',
          stats['processing']?.toString() ?? '0',
          Icons.pending,
          Colors.blueAccent,
        ),
        _buildStatCard(
          'تم الحل',
          stats['resolved']?.toString() ?? '0',
          Icons.check_circle,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementMenu(BuildContext context) {
    List<Map<String, dynamic>> menuItems = [
      {
        'title': 'إدارة الجهات الخدمية',
        'icon': Icons.business,
        'color': Colors.purple,
        'onTap': () {},
      },
      {
        'title': 'إدارة الموظفين',
        'icon': Icons.people,
        'color': Colors.teal,
        'onTap': () {},
      },
      {
        'title': 'تقارير وإحصائيات',
        'icon': Icons.bar_chart,
        'color': Colors.indigo,
        'onTap': () {},
      },
      {
        'title': 'إعدادات النظام',
        'icon': Icons.settings,
        'color': Colors.grey,
        'onTap': () {},
      },
    ];

    return Column(
      children: menuItems.map((item) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: item['color'].withOpacity(0.1),
              child: Icon(item['icon'], color: item['color']),
            ),
            title: Text(item['title']),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: item['onTap'],
          ),
        );
      }).toList(),
    );
  }
}
