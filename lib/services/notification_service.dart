import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Navigation key for routing from notifications
  static GlobalKey<NavigatorState>? navigatorKey;
  
  // Callback for when badge count changes
  static Function(int)? onBadgeUpdated;

  /// Initialize notification service
  static Future<void> initialize() async {
    try {
      print('=== INITIALIZING NOTIFICATION SERVICE ===');
      
      // Initialize local notifications
      const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initializationSettings = InitializationSettings(
        iOS: initializationSettingsIOS,
      );
      
      await _localNotifications.initialize(initializationSettings);
      
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permissions granted');
        
        // Wait for APNS token on iOS
        try {
          String? apnsToken = await _firebaseMessaging.getAPNSToken();
          if (apnsToken != null) {
            print('✅ APNS Token received: ${apnsToken.substring(0, 20)}...');
          } else {
            print('⚠️ APNS Token not yet available, waiting...');
            // Wait a bit and try again
            await Future.delayed(Duration(seconds: 2));
            apnsToken = await _firebaseMessaging.getAPNSToken();
            if (apnsToken != null) {
              print('✅ APNS Token received after delay: ${apnsToken.substring(0, 20)}...');
            }
          }
        } catch (e) {
          print('⚠️ Could not get APNS token: $e');
        }
        
        // Get FCM token
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          print('FCM Token received: ${token.substring(0, 20)}...');
          await _saveTokenToPreferences(token);
        } else {
          print('⚠️ FCM Token not received');
        }

        // Subscribe to topics
        await _firebaseMessaging.subscribeToTopic('all_users');
        await _firebaseMessaging.subscribeToTopic('ieu_updates');
        print('✅ Subscribed to topics');
        
        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) async {
          print('🔄 FCM Token refreshed');
          await _saveTokenToPreferences(newToken);
        });

        // Setup message handlers
        _setupMessageHandlers();
        
        // Load saved badge count
        await loadBadgeCount();
        
        print('✅ Notification service initialized successfully');
      } else {
        print('❌ Notification permissions denied');
      }
    } catch (e) {
      print('❌ Error initializing notification service: $e');
    }
  }

  /// Setup message handlers
  static void _setupMessageHandlers() {
    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle messages when app is opened from terminated state
    _handleInitialMessage();
  }

  /// Handle message tap (when notification is clicked)
  static Future<void> _handleMessageTap(RemoteMessage message) async {
    try {
      print('=== MESSAGE TAPPED ===');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
      
      // Handle notification routing based on data
      await _handleNotificationRouting(message);
    } catch (e) {
      print('Error handling message tap: $e');
    }
  }

  /// Handle foreground messages (when app is active)
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      print('=== FOREGROUND MESSAGE RECEIVED ===');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
      
      // For foreground messages, you can show in-app notification
      // or update badge count
      if (onBadgeUpdated != null) {
        // Increment badge count (simplified implementation)
        // In a real app, you'd get this from a database
        onBadgeUpdated!(1);
      }
    } catch (e) {
      print('Error handling foreground message: $e');
    }
  }

  /// Handle notification routing (duyuru, link or normal)
  static Future<void> _handleNotificationRouting(RemoteMessage message) async {
    print('=== HANDLING NOTIFICATION ROUTING ===');
    
    if (navigatorKey?.currentContext == null) {
      print('⚠️ Navigator context not available');
      return;
    }

    final context = navigatorKey!.currentContext!;
    final data = message.data;
    
    final link = data['link'];
    final screen = data['screen'];
    
    print('🔗 Link: $link');
    print('📱 Screen: $screen');

    // Route based on data
    if (link != null && link.toString().isNotEmpty) {
      // Open external link
      print('🌐 Opening external link: $link');
      await _openExternalLink(link.toString());
    } else if (screen != null) {
      // Navigate to specific screen
      print('📱 Navigating to screen: $screen');
      _navigateToScreen(context, screen.toString());
    } else {
      // Default: navigate to notifications
      print('📋 Navigating to notifications screen');
      _navigateToNotifications(context);
    }
  }

  /// Handle initial message (app opened from terminated state)
  static Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    
    if (initialMessage != null) {
      print('=== INITIAL MESSAGE FOUND ===');
      await _handleMessageTap(initialMessage);
    }
  }

  /// Open external link
  static Future<void> _openExternalLink(String url) async {
    // Implementation would use url_launcher
    print('Would open URL: $url');
  }

  /// Navigate to specific screen
  static void _navigateToScreen(BuildContext context, String screen) {
    // Implementation would navigate based on screen parameter
    print('Would navigate to screen: $screen');
  }

  /// Navigate to notifications screen
  static void _navigateToNotifications(BuildContext context) {
    // Implementation would navigate to notifications screen
    print('Would navigate to notifications screen');
  }

  /// Save FCM token to SharedPreferences
  static Future<void> _saveTokenToPreferences(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      print('✅ FCM Token saved to preferences');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  /// Get FCM token from SharedPreferences
  static Future<String?> getTokenFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Get current FCM token
  static Future<String?> getCurrentToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('❌ Error getting current FCM token: $e');
      return null;
    }
  }

  /// Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Check notification permission status
  static Future<bool> isPermissionGranted() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('❌ Error checking permission: $e');
      return false;
    }
  }

  /// Badge count management
  static int _badgeCount = 0;
  
  static int get badgeCount => _badgeCount;
  
  /// Update app badge count
  static Future<void> updateBadgeCount(int count) async {
    _badgeCount = count;
    
    try {
      // Update app badge using app_badge_plus
      if (count > 0) {
        await AppBadgePlus.updateBadge(count);
      } else {
        await AppBadgePlus.updateBadge(0);
      }
      
      // Store in SharedPreferences as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('app_badge_count', count);
      
      // Call the callback if available
      onBadgeUpdated?.call(count);
      
      print('🏷️ Badge count updated: $count');
    } catch (e) {
      print('❌ Badge update error: $e');
    }
  }
  
  /// Load saved badge count
  static Future<void> loadBadgeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _badgeCount = prefs.getInt('app_badge_count') ?? 0;
      
      // For iOS, badge will be managed through Firebase Messaging
      // No need to manually sync here
      
      onBadgeUpdated?.call(_badgeCount);
    } catch (e) {
      print('❌ Badge load error: $e');
    }
  }
  
  /// Clear badge count
  static Future<void> clearBadge() async {
    await updateBadgeCount(0);
  }
  
  // === YENİ BİLDİRİM YÖNETİMİ ===
  
  static final DatabaseReference _notificationsRef = FirebaseDatabase.instance.ref('notifications');
  static final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  
  /// Tüm bildirimleri getir
  static Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final snapshot = await _notificationsRef.get();
      if (!snapshot.exists) return [];
      
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final notifications = <NotificationModel>[];
      
      data.forEach((id, notificationData) {
        notifications.add(NotificationModel.fromMap(id, Map<String, dynamic>.from(notificationData)));
      });
      
      // Timestamp'e göre sırala (en yeni en üstte)
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return notifications;
    } catch (e) {
      print('❌ Bildirimler alınamadı: $e');
      return [];
    }
  }
  
  /// Kullanıcının bildirimlerini getir (okunmamış + okunmuş, silinmemişler)
  static Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return [];
      
      final allNotifications = await getAllNotifications();
      
      // Silinmemiş bildirimleri filtrele
      final userNotifications = allNotifications.where((notification) {
        return !user.deletedNotifications.containsKey(notification.id);
      }).toList();
      
      return userNotifications;
    } catch (e) {
      print('❌ Kullanıcı bildirimleri alınamadı: $e');
      return [];
    }
  }
  
  /// Bildirimi okundu olarak işaretle
  static Future<void> markAsRead(String notificationId) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return;
      
      // User'da okundu olarak işaretle
      await _usersRef.child(user.id).child('notifications/read/$notificationId').set(true);
      
      // Kullanıcı verilerini yenile
      await AuthService().refreshUserData();
      
      // Okunmamış sayısını güncelle
      await _updateUnreadCount();
      
      // Badge callback'ini çağır
      if (onBadgeUpdated != null) {
        final updatedUser = AuthService().currentUser;
        if (updatedUser != null) {
          onBadgeUpdated!(updatedUser.unreadCount);
        }
      }
      
      print('✅ Bildirim okundu olarak işaretlendi: $notificationId');
    } catch (e) {
      print('❌ Bildirim okundu işaretlenemedi: $e');
    }
  }
  
  /// Bildirimi sil
  static Future<void> deleteNotification(String notificationId) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return;
      
      // User'da silindi olarak işaretle
      await _usersRef.child(user.id).child('notifications/delete/$notificationId').set(true);
      
      // Kullanıcı verilerini yenile
      await AuthService().refreshUserData();
      
      // Okunmamış sayısını güncelle
      await _updateUnreadCount();
      
      // Badge callback'ini çağır
      if (onBadgeUpdated != null) {
        final updatedUser = AuthService().currentUser;
        if (updatedUser != null) {
          onBadgeUpdated!(updatedUser.unreadCount);
        }
      }
      
      print('✅ Bildirim silindi: $notificationId');
    } catch (e) {
      print('❌ Bildirim silinemedi: $e');
    }
  }
  
  /// Tüm bildirimleri okundu olarak işaretle
  static Future<void> markAllAsRead() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return;
      
      final allNotifications = await getAllNotifications();
      
      // Okunmamış ve silinmemiş bildirimleri bul
      final unreadNotifications = allNotifications.where((notification) {
        final isDeleted = user.deletedNotifications.containsKey(notification.id);
        final isRead = user.readNotifications.containsKey(notification.id);
        return !isDeleted && !isRead;
      }).toList();
      
      if (unreadNotifications.isEmpty) return;
      
      // Toplu güncelleme için map hazırla
      final updates = <String, dynamic>{};
      for (final notification in unreadNotifications) {
        updates['notifications/read/${notification.id}'] = true;
      }
      
      // Tek seferde tüm güncellemeleri yap
      await _usersRef.child(user.id).update(updates);
      
      // Kullanıcı verilerini yenile
      await AuthService().refreshUserData();
      
      // Okunmamış sayısını güncelle
      await _updateUnreadCount();
      
      print('✅ ${unreadNotifications.length} bildirim toplu olarak okundu işaretlendi');
    } catch (e) {
      print('❌ Toplu bildirim okuma hatası: $e');
    }
  }
  
  /// Okunmamış bildirim sayısını güncelle
  static Future<void> _updateUnreadCount() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return;
      
      final allNotifications = await getAllNotifications();
      
      // Okunmamış ve silinmemiş bildirimleri say
      int unreadCount = 0;
      for (final notification in allNotifications) {
        final isDeleted = user.deletedNotifications.containsKey(notification.id);
        final isRead = user.readNotifications.containsKey(notification.id);
        
        if (!isDeleted && !isRead) {
          unreadCount++;
        }
      }
      
      // Veritabanında güncelle
      await _usersRef.child(user.id).child('notifications/unread_count').set(unreadCount);
      
      // App badge'ı güncelle
      await updateBadgeCount(unreadCount);
      
      print('✅ Okunmamış bildirim sayısı güncellendi: $unreadCount');
    } catch (e) {
      print('❌ Okunmamış sayı güncellenemedi: $e');
    }
  }
  
  /// Okunmamış bildirim sayısını getir
  static Future<int> getUnreadCount() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return 0;
      
      final snapshot = await _usersRef.child(user.id).child('notifications/unread_count').get();
      return snapshot.value as int? ?? 0;
    } catch (e) {
      print('❌ Okunmamış sayı alınamadı: $e');
      return 0;
    }
  }
  
  /// Kullanıcının bildirimlerini yeniden hesapla ve güncelle
  static Future<void> refreshUserNotifications() async {
    try {
      // Önce kullanıcı verilerini yenile
      await AuthService().refreshUserData();
      
      // Sonra unread count'u güncelle
      await _updateUnreadCount();
      
      print('✅ Kullanıcı bildirimleri yenilendi');
    } catch (e) {
      print('❌ Kullanıcı bildirimlerini yenileme hatası: $e');
    }
  }
}
