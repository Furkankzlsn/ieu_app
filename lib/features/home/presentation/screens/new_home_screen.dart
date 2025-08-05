import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/home_slider_widget.dart';
import '../../../../shared/widgets/compact_news_widget.dart';
import '../../../../shared/widgets/compact_announcements_widget.dart';
import '../../../../shared/widgets/ieu_values_widget.dart';
import '../../../../shared/widgets/main_navigation_menu.dart';
import '../../../../shared/utils/webview_utils.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/badge_service.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/slider_service.dart';
import '../../../../services/news_service.dart';
import '../../../../services/announcement_service.dart';
import '../../../../models/slider_model.dart';
import '../../../../models/news_model.dart';
import '../../../../models/announcement_model.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({Key? key}) : super(key: key);

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> 
    with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  final BadgeService _badgeService = BadgeService();
  final SliderService _sliderService = SliderService();
  final NewsService _newsService = NewsService();
  final AnnouncementService _announcementService = AnnouncementService();
  final ScrollController _scrollController = ScrollController();
  
  List<SliderModel> _sliders = [];
  List<NewsModel> _news = [];
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = true;
  int _notificationBadgeCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _setupNotificationBadgeListener();
    _loadNotificationBadgeCount();
  }
  
  void _setupNotificationBadgeListener() {
    // Notification service'ten badge güncellemelerini dinle
    NotificationService.onBadgeUpdated = (count) {
      if (mounted) {
        setState(() {
          _notificationBadgeCount = count;
        });
      }
    };
  }

  Future<void> _loadNotificationBadgeCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _notificationBadgeCount = count;
        });
      }
    } catch (e) {
      print('❌ Badge count yüklenemedi: $e');
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App resume olduğunda badge'leri güncelle
      _refreshBadges();
      // Notification badge'ını da güncelle
      _loadNotificationBadgeCount();
      // Notification service'te de refresh yap
      NotificationService.refreshUserNotifications();
    }
  }

  Future<void> _refreshBadges() async {
    await _badgeService.updateAllBadges();
  }

  Future<void> _onRefresh() async {
    // Refresh all data
    await _loadData();
    await _refreshBadges();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Paralel olarak slider, news ve duyuru verilerini yükle
      final results = await Future.wait([
        _sliderService.getSliders(),
        _newsService.getNews(limit: 5),
        _announcementService.getAnnouncements(limit: 3),
      ]);

      setState(() {
        _sliders = results[0] as List<SliderModel>;
        _news = results[1] as List<NewsModel>;
        _announcements = results[2] as List<AnnouncementModel>;
        _isLoading = false;
      });

      print('✅ Ana sayfa verileri yüklendi: ${_sliders.length} slider, ${_news.length} haber, ${_announcements.length} duyuru');
      print('🔍 Slider verileri: ${_sliders.map((s) => s.baslik).toList()}');
      print('🔍 News verileri: ${_news.map((n) => n.baslik).toList()}');
      print('🔍 Announcement verileri: ${_announcements.map((a) => a.baslik).toList()}');
    } catch (e) {
      print('❌ Ana sayfa veri yükleme hatası: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isStudent = _authService.isLoggedIn;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Compact App Bar
            SliverAppBar(
              expandedHeight: 60,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: null,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              // Logo
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.asset(
                                    'assets/images/ieu_logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.school,
                                        color: AppColors.primaryColor,
                                        size: 20,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Welcome text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isStudent ? 'Hoşgeldin' : 'İEÜ\'ye Hoşgeldin',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      isStudent 
                                          ? (user?.displayName ?? 'Öğrenci')
                                          : 'Misafir Kullanıcı',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Action buttons
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      // Bildirimler sayfasına git
                                      await Navigator.pushNamed(context, '/notifications');
                                      // Geri döndüğünde badge'ı güncelle
                                      await _loadNotificationBadgeCount();
                                    },
                                    icon: Stack(
                                      children: [
                                        const Icon(
                                          Icons.notifications_outlined,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        if (_notificationBadgeCount > 0)
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: AppColors.errorColor,
                                                shape: BoxShape.circle,
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 16,
                                                minHeight: 16,
                                              ),
                                              child: Text(
                                                _notificationBadgeCount > 99 ? '99+' : _notificationBadgeCount.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                                    icon: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        isStudent ? Icons.person : Icons.person_outline,
                                        color: AppColors.primaryColor,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Loading indicator
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    )
                  else ...[
                    // Hero Slider
                    HomeSliderWidget(
                      sliders: _sliders,
                    ),
                    
                    // Quick Actions (for non-students)
                    if (!isStudent) ...[
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Main Navigation Menu
                    const MainNavigationMenu(),
                    
                    const SizedBox(height: 24),
                    
                    // News Section  
                    CompactNewsWidget(
                      newsList: _news,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Announcements Section
                    CompactAnnouncementsWidget(announcements: _announcements),
                    
                    const SizedBox(height: 16),

                    
                    const SizedBox(height: 16),
                    
                    // IEU Values Section
                    const IeuValuesWidget(),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Campus Info Section
                  _buildCampusInfo(),
                  
                  const SizedBox(height: 32),
                  
                  // Footer
                  _buildFooter(),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hızlı Erişim',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Aday Öğrenci',
                  'Başvuru ve kayıt',
                  Icons.school,
                  AppColors.primaryColor,
                  () => print('Navigate to candidate student'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Öğrenci Girişi',
                  'Sisteme giriş yap',
                  Icons.login,
                  AppColors.successColor,
                  () => Navigator.pushNamed(context, '/profile'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampusInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            openWebView(
              context,
              'https://www.ieu.edu.tr/tr/news/type/read/id/9251',
              title: 'Güzelbahçe Kampüsü',
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
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
              children: [
                // Campus image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    'https://ieu.edu.tr/images/kampus35.jpg',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 180,
                        color: AppColors.primaryColor.withOpacity(0.1),
                        child: const Icon(
                          Icons.landscape,
                          size: 50,
                          color: AppColors.primaryColor,
                        ),
                      );
                    },
                  ),
                ),
                // Content below image
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İZMİR EKONOMİ ÜNİVERSİTESİ',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Güzelbahçe Kampüsü - İzmir',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Detaylar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Social media icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.facebook, () => print('Facebook')),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.camera_alt, () => print('Instagram')),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.alternate_email, () => print('Twitter')),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.play_arrow, () => print('YouTube')),
            ],
          ),
          const SizedBox(height: 16),
          // Links
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildFooterLink('Üniversite', () => print('University')),
              _buildFooterLink('Akademik', () => print('Academic')),
              _buildFooterLink('Araştırma', () => print('Research')),
              _buildFooterLink('Kampüs', () => print('Campus')),
              _buildFooterLink('İletişim', () => print('Contact')),
            ],
          ),
          const SizedBox(height: 16),
          // Copyright
          Text(
            '© 2025 İzmir Ekonomi Üniversitesi\nTüm hakları saklıdır.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textColor.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryColor,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFooterLink(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
