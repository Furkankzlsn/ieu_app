import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/api_service.dart';
import '../../../../models/user_model.dart';
import '../../../examschedule/presentation/screens/exam_schedule_screen.dart';
import '../../../courseschedule/presentation/screens/course_schedule_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen>
    with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isStudent = _authService.isLoggedIn;

    if (!isStudent || user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Öğrenci girişi yapmanız gerekiyor',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/profile'),
                child: const Text('Giriş Yap'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo/ieu_logo.png',
              height: 32,
              width: 32,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.school, size: 32, color: Colors.white);
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'Öğrenci Paneli',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              _buildWelcomeCard(user),

              const SizedBox(height: 24),

              // Quick Actions Grid
              const Text(
                'Hızlı İşlemler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 16),

              _buildQuickActionsGrid(),

              const SizedBox(height: 24),

              // Student Info Card
              _buildStudentInfoCard(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  _getInitials(user.displayName ?? 'İÖ'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hoş Geldiniz',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      user.displayName ?? 'İzmir Ekonomi Öğrencisi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'İEU Öğrenci Sistemi',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ekran genişliğine göre ayarlama
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: isSmallScreen ? 12 : 16,
          mainAxisSpacing: isSmallScreen ? 12 : 16,
          childAspectRatio: isSmallScreen ? 1.0 : 1.1,
          children: [
            _buildQuickActionCard(
              'Sınav Programı',
              'Sınav takvimini görüntüle',
              Icons.assignment_turned_in,
              Colors.blue,
              () => _navigateToExamSchedule(),
            ),
            _buildQuickActionCard(
              'Ders Programı',
              'Haftalık ders programı',
              Icons.schedule,
              Colors.green,
              () => _navigateToCourseSchedule(),
            ),
            _buildQuickActionCard(
              'Notlar',
              'Akademik sonuçlar',
              Icons.grade,
              Colors.orange,
              () => _showComingSoon('Notlar'),
            ),
            _buildQuickActionCard(
              'Transkript',
              'Akademik geçmiş',
              Icons.description,
              Colors.purple,
              () => _showComingSoon('Transkript'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Kart boyutuna göre font ayarlama
        final cardWidth = constraints.maxWidth;
        final isSmallCard = cardWidth < 160;

        final titleFontSize = isSmallCard ? 14.0 : 16.0;
        final subtitleFontSize = isSmallCard ? 10.0 : 12.0;
        final iconSize = isSmallCard ? 28.0 : 32.0;
        final padding = isSmallCard ? 12.0 : 16.0;
        final iconPadding = isSmallCard ? 8.0 : 12.0;
        final spacing = isSmallCard ? 8.0 : 12.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(iconPadding),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: iconSize),
                  ),
                  SizedBox(height: spacing),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentInfoCard(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Öğrenci Bilgileri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Ad Soyad', user.displayName ?? 'Bilinmiyor'),
          _buildInfoRow('E-posta', user.email),
          _buildInfoRow('Öğrenci No', user.studentNumber ?? 'Bilinmiyor'),
          _buildInfoRow('Bölüm', user.department ?? 'Bilinmiyor'),
          _buildInfoRow(
            'Sınıf',
            user.grade != null ? '${user.grade}. Sınıf' : 'Bilinmiyor',
          ),
          _buildInfoRow(
            'Kayıt Yılı',
            user.enrollmentYear?.toString() ?? 'Bilinmiyor',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.isEmpty) return 'İÖ';
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'
        .toUpperCase();
  }

  void _navigateToExamSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExamScheduleScreen()),
    );
  }

  void _navigateToCourseSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CourseScheduleScreen()),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature özelliği yakında eklenecek'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }
}
