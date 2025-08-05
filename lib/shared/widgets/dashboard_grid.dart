import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../../services/badge_service.dart';

class DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badgeCount;

  DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount,
  });
}

class DashboardGrid extends StatefulWidget {
  final int crossAxisCount;
  final VoidCallback? onBadgeRefreshRequested;

  const DashboardGrid({
    Key? key,
    this.crossAxisCount = 2,
    this.onBadgeRefreshRequested,
  }) : super(key: key);

  @override
  State<DashboardGrid> createState() => _DashboardGridState();
  
  // Static method to refresh badges from outside
  static Future<void> refreshBadgesFromOutside() async {
    await _DashboardGridState.refreshBadgesFromOutside();
  }
}

class _DashboardGridState extends State<DashboardGrid> {
  final BadgeService _badgeService = BadgeService();
  int _announcementBadge = 0;
  int _notificationBadge = 0;
  
  // Static method for external refresh calls
  static _DashboardGridState? _currentInstance;

  @override
  void initState() {
    super.initState();
    _currentInstance = this;
    _loadBadges();
  }
  
  @override
  void dispose() {
    if (_currentInstance == this) {
      _currentInstance = null;
    }
    super.dispose();
  }
  
  // Static method to refresh from outside
  static Future<void> refreshBadgesFromOutside() async {
    await _currentInstance?._loadBadges();
  }

  Future<void> _loadBadges() async {
    await _badgeService.updateAllBadges();
    if (mounted) {
      setState(() {
        _announcementBadge = 0; // Duyuru badge'ı devre dışı - sadece bildirimler kullanılacak
        _notificationBadge = _badgeService.unreadNotifications;
      });
    }
  }

  // Public method for external refresh
  Future<void> refreshBadges() async {
    await _loadBadges();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isStudent = authService.isLoggedIn;
    
    // Anonim kullanıcı için öğeler
    final List<DashboardItem> anonymousItems = [
      DashboardItem(
        title: 'Duyurular',
        subtitle: 'Genel duyurular',
        icon: Icons.announcement,
        color: AppColors.primaryColor,
        onTap: () => Navigator.pushNamed(context, '/announcements'),
        badgeCount: _announcementBadge,
      ),
      DashboardItem(
        title: 'Bildirimler',
        subtitle: 'Bildirimlerim',
        icon: Icons.notifications,
        color: AppColors.accentColor,
        onTap: () => Navigator.pushNamed(context, '/notifications'),
        badgeCount: _notificationBadge,
      ),
      DashboardItem(
        title: 'Giriş Yap',
        subtitle: 'Öğrenci girişi',
        icon: Icons.login,
        color: AppColors.successColor,
        onTap: () => Navigator.pushNamed(context, '/profile'),
      ),
      DashboardItem(
        title: 'İletişim',
        subtitle: 'Bilgi ve destek',
        icon: Icons.contact_support,
        color: AppColors.infoColor,
        onTap: () => _showComingSoon(context, 'İletişim'),
      ),
    ];

    // Öğrenci kullanıcı için öğeler
    final List<DashboardItem> studentItems = [
      DashboardItem(
        title: 'Duyurular',
        subtitle: 'Güncel duyurular',
        icon: Icons.announcement,
        color: AppColors.primaryColor,
        onTap: () => Navigator.pushNamed(context, '/announcements'),
        badgeCount: _announcementBadge,
      ),
      DashboardItem(
        title: 'Bildirimler',
        subtitle: 'Bildirimlerim',
        icon: Icons.notifications,
        color: AppColors.accentColor,
        onTap: () => Navigator.pushNamed(context, '/notifications'),
        badgeCount: _notificationBadge,
      ),
      DashboardItem(
        title: 'Sınav Takvimi',
        subtitle: 'Sınav programı',
        icon: Icons.event_note,
        color: AppColors.successColor,
        onTap: () => _showComingSoon(context, 'Sınav Takvimi'),
      ),
      DashboardItem(
        title: 'Ödevler',
        subtitle: 'Ödev takibi',
        icon: Icons.assignment,
        color: AppColors.errorColor,
        onTap: () => _showComingSoon(context, 'Ödevler'),
      ),
      DashboardItem(
        title: 'Not Durumu',
        subtitle: 'Notlarım',
        icon: Icons.grade,
        color: AppColors.warningColor,
        onTap: () => _showComingSoon(context, 'Not Durumu'),
      ),
      DashboardItem(
        title: 'Ders Programı',
        subtitle: 'Haftalık program',
        icon: Icons.schedule,
        color: AppColors.infoColor,
        onTap: () => _showComingSoon(context, 'Ders Programı'),
      ),
      DashboardItem(
        title: 'Kütüphane',
        subtitle: 'Kitap işlemleri',
        icon: Icons.library_books,
        color: Colors.purple,
        onTap: () => _showComingSoon(context, 'Kütüphane'),
      ),
      DashboardItem(
        title: 'Mali Durum',
        subtitle: 'Ödemeler',
        icon: Icons.account_balance_wallet,
        color: Colors.green,
        onTap: () => _showComingSoon(context, 'Mali Durum'),
      ),
    ];

    final items = isStudent ? studentItems : anonymousItems;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: AppSizes.defaultPadding,
        mainAxisSpacing: AppSizes.defaultPadding,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return DashboardCard(item: items[index]);
      },
    );
  }

  static void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('Bu özellik yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final DashboardItem item;

  const DashboardCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      size: 32,
                      color: item.color,
                    ),
                  ),
                  // Badge
                  if (item.badgeCount != null && item.badgeCount! > 0)
                    Positioned(
                      top: -5,
                      right: -5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          item.badgeCount! > 99 ? '99+' : item.badgeCount.toString(),
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
              const SizedBox(height: 12),
              // Title
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Subtitle
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 12,
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
}
