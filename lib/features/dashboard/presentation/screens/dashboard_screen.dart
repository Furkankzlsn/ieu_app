import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../shared/widgets/dashboard_grid.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/badge_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> 
    with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  final BadgeService _badgeService = BadgeService();
  
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
    if (state == AppLifecycleState.resumed) {
      // App resume olduğunda badge'leri güncelle
      _refreshBadges();
    }
  }

  Future<void> _refreshBadges() async {
    await _badgeService.updateAllBadges();
    await DashboardGrid.refreshBadgesFromOutside();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isStudent = _authService.isLoggedIn;
    
    print('🔍 Dashboard Build - User: ${user?.displayName}, isStudent: $isStudent, userType: ${_authService.userType}');

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
                return const Icon(
                  Icons.school,
                  size: 32,
                  color: AppColors.primaryColor,
                );
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'İEU Öğrenci',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.primaryColor.withOpacity(0.1),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
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
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
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
                    Text(
                      isStudent ? 'Hoş Geldin!' : 'Hoş Geldin!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.displayName ?? 'Misafir Kullanıcı',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isStudent 
                        ? 'Öğrenci paneline erişiminiz bulunmaktadır.'
                        : 'Daha fazla özellik için giriş yapabilirsiniz.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Quick Stats (only for students)
              if (isStudent) ...[
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.assignment_turned_in,
                              color: AppColors.successColor,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '3',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const Text(
                              'Tamamlanan',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.pending_actions,
                              color: AppColors.warningColor,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '2',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const Text(
                              'Bekleyen',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              
              // Services Grid
              const Text(
                'Hizmetler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 16),
              const DashboardGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
