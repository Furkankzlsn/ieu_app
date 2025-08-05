import '../services/auth_service.dart';
import '../services/notification_service.dart';

class BadgeService {
  static final BadgeService _instance = BadgeService._internal();
  factory BadgeService() => _instance;
  BadgeService._internal();

  final AuthService _authService = AuthService();
  
  int _unreadNotifications = 0;
  int _unreadAnnouncements = 0;
  
  int get unreadNotifications => _unreadNotifications;
  int get unreadAnnouncements => _unreadAnnouncements;
  int get totalUnread => _unreadNotifications + _unreadAnnouncements;

  /// Initialize badge service
  Future<void> initialize() async {
    // Bildirim sistemini reset et - şu anda Firebase'te bildirim yok
    _unreadNotifications = 0;
    _unreadAnnouncements = 0;
    
    // App badge'ı 0'la
    await NotificationService.updateBadgeCount(0);
    print('🏷️ Badge service initialized - all counts reset to 0');
  }

  /// Update all badge counts
  Future<void> updateAllBadges() async {
    await updateNotificationBadge();
    
    // Update app badge (dış badge - sadece bildirimler)
    // Notification Service kendi içinde badge'ı güncelliyor, burada tekrar çağırmaya gerek yok
    print('🏷️ Badge count updated: $_unreadNotifications');
  }

  /// Update notification badge count
  Future<void> updateNotificationBadge() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        _unreadNotifications = 0;
        return;
      }

      // Yeni bildirim sisteminden okunmamış sayısını al
      _unreadNotifications = await NotificationService.getUnreadCount();
      print('🏷️ Notification badge updated: $_unreadNotifications');
    } catch (e) {
      print('❌ Notification badge update error: $e');
      _unreadNotifications = 0;
    }
  }

  /// Update announcement badge count (DEVRE DIŞI - artık kullanılmıyor)
  Future<void> updateAnnouncementBadge() async {
    // Duyuru badge'ını devre dışı bıraktık - sadece bildirimler kullanılacak
    _unreadAnnouncements = 0;
    print('🚫 Announcement badge disabled - using notifications only');
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _authService.markNotificationAsRead(notificationId);
    await updateNotificationBadge();
    await NotificationService.updateBadgeCount(totalUnread);
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _authService.deleteNotification(notificationId);
    await updateNotificationBadge();
    await NotificationService.updateBadgeCount(totalUnread);
  }

  /// Mark announcement as read
  Future<void> markAnnouncementAsRead(String announcementId) async {
    await _authService.markAnnouncementAsRead(announcementId);
    await updateAnnouncementBadge();
    await NotificationService.updateBadgeCount(totalUnread);
  }

  /// Reset all badges (when user logs out/in)
  Future<void> resetBadges() async {
    _unreadNotifications = 0;
    _unreadAnnouncements = 0;
    await NotificationService.clearBadge();
  }
}
