import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebalagh_app/services/auth_service.dart';
import 'submit_report_screen.dart';
import 'my_reports_screen.dart';

/// الصفحة الرئيسية للمواطن
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(user?.fullName ?? 'مستخدم'),
            const SizedBox(height: 24),
            _buildStatisticsSection(context),
            const SizedBox(height: 24),
            Text(
              'الخدمات',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildServicesGrid(context),
            const SizedBox(height: 24),
            Text(
              'آخر البلاغات',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildRecentReportsPreview(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String userName) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أهلاً بك،',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ساهم في تحسين خدمات محافظة شبوة\nمن خلال الإبلاغ عن الأعطال',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(
          context,
          title: 'بلاغاتي',
          value: '5',
          icon: Icons.report,
          color: Colors.orange,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          context,
          title: 'قيد المعالجة',
          value: '2',
          icon: Icons.pending_actions,
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          context,
          title: 'تم الحل',
          value: '3',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    List<Map<String, dynamic>> services = [
      {
        'title': 'بلاغ جديد',
        'icon': Icons.add_circle,
        'color': Colors.green,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SubmitReportScreen(),
            ),
          );
        },
      },
      {
        'title': 'بلاغاتي',
        'icon': Icons.list_alt,
        'color': Colors.blue,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyReportsScreen(),
            ),
          );
        },
      },
      {
        'title': 'الجهات الخدمية',
        'icon': Icons.business,
        'color': Colors.purple,
        'onTap': () {},
      },
      {
        'title': 'المساعدة',
        'icon': Icons.help,
        'color': Colors.orange,
        'onTap': () {},
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(
          title: services[index]['title'],
          icon: services[index]['icon'],
          color: services[index]['color'],
          onTap: services[index]['onTap'],
        );
      },
    );
  }

  Widget _buildServiceCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReportsPreview(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.report_problem, color: Colors.orange),
        title: const Text('عطل كهرباء - شارع الجمهورية'),
        subtitle: const Text('قيد المعالجة'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyReportsScreen(),
            ),
          );
        },
      ),
    );
  }
}
