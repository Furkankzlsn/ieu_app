import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../models/notification_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../shared/utils/webview_utils.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      _currentUser = AuthService().currentUser;
      _notifications = await NotificationService.getUserNotifications();
      
      print('📋 ${_notifications.length} bildirim yüklendi');
    } catch (e) {
      print('❌ Bildirimler yüklenemedi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Yerel state'i güncelle (tüm listeyi yeniden yüklemek yerine)
  void _updateLocalNotificationState(String notificationId, {bool? isRead, bool? isDeleted}) async {
    // Önce AuthService'i yenile ki güncel user data'ya sahip olalım
    await AuthService().refreshUserData();
    
    setState(() {
      // Güncellenmiş kullanıcı verilerini AuthService'den al
      _currentUser = AuthService().currentUser;
      
      // Eğer bildirim silindiyse, listeden çıkar
      if (isDeleted == true) {
        _notifications.removeWhere((notification) => notification.id == notificationId);
        print('📋 Bildirim yerel listeden silindi: $notificationId');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Bildirimler',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 2,
          iconTheme: const IconThemeData(color: AppColors.primaryColor),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
      );
    }

    final unreadNotifications = _notifications.where((n) => !_isNotificationRead(n)).toList();
    final unreadCount = unreadNotifications.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Bildirimler',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Tümünü Okundu İşaretle',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          IconButton(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: AppColors.textColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz bildirim bulunmuyor',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (unreadCount > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.defaultPadding,
                      vertical: 12,
                    ),
                    color: AppColors.primaryColor.withOpacity(0.1),
                    child: Text(
                      '$unreadCount okunmamış bildirim',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSizes.defaultPadding),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return _buildNotificationCard(notification);
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final isRead = _isNotificationRead(notification);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: isRead 
            ? null 
            : Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          onTap: () => _onNotificationTap(notification),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: isRead 
                                    ? FontWeight.w500 
                                    : FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          color: AppColors.textColor.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textColor.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(notification.dateTime),
                            style: TextStyle(
                              color: AppColors.textColor.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // More Options
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textColor.withOpacity(0.5),
                    size: 20,
                  ),
                  onSelected: (value) => _onMenuAction(value, notification),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: isRead ? 'unread' : 'read',
                      child: Text(
                        isRead ? 'Okunmadı işaretle' : 'Okundu işaretle',
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Sil'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isNotificationRead(NotificationModel notification) {
    return _currentUser?.readNotifications.containsKey(notification.id) ?? false;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _onNotificationTap(NotificationModel notification) async {
    // Bildirimi okundu olarak işaretle
    if (!_isNotificationRead(notification)) {
      await NotificationService.markAsRead(notification.id);
      // Yerel state'i güncelle (tüm listeyi yeniden yüklemek yerine)
      _updateLocalNotificationState(notification.id, isRead: true);
    }

    // Bildirim türüne göre yönlendirme
    if (notification.link != null && notification.link!.isNotEmpty) {
      // Link varsa webview aç
      await _openLink(notification.link!);
    } else {
      // Yoksa popup göster
      _showNotificationDetail(notification);
    }
  }

  Future<void> _openLink(String url) async {
    try {
      // WebView ile aç
      openWebView(
        context,
        url,
        title: 'Bildirim',
      );
    } catch (e) {
      _showErrorDialog('Link açılırken hata oluştu: $e');
    }
  }

  void _showNotificationDetail(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: SingleChildScrollView(
          child: Text(notification.body),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _onMenuAction(String action, NotificationModel notification) async {
    switch (action) {
      case 'read':
        await NotificationService.markAsRead(notification.id);
        // Yerel state'i güncelle (tüm listeyi yeniden yüklemek yerine)
        _updateLocalNotificationState(notification.id, isRead: true);
        break;
      case 'unread':
        // Okunmadı işaretleme - şimdilik desteklenmiyor
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Okunmadı işaretleme şu anda desteklenmiyor')),
          );
        }
        break;
      case 'delete':
        _showDeleteConfirmation(notification);
        break;
    }
  }

  void _markAllAsRead() async {
    final unreadNotifications = _notifications.where((n) => !_isNotificationRead(n)).toList();
    
    if (unreadNotifications.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zaten tüm bildirimler okunmuş')),
        );
      }
      return;
    }
    
    // Toplu okundu işaretleme kullan
    await NotificationService.markAllAsRead();
    
    // Yerel state'i güncelle (tüm listeyi yeniden yüklemek yerine)
    setState(() {
      _currentUser = AuthService().currentUser;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${unreadNotifications.length} bildirim okundu olarak işaretlendi')),
      );
    }
  }

  void _showDeleteConfirmation(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirimi Sil'),
        content: const Text('Bu bildirimi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await NotificationService.deleteNotification(notification.id);
              // Yerel state'i güncelle (tüm listeyi yeniden yüklemek yerine)
              _updateLocalNotificationState(notification.id, isDeleted: true);
              
              // Widget hala mounted durumunda mı kontrol et
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bildirim silindi')),
                );
              }
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
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
