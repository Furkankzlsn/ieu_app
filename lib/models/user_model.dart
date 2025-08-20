import 'announcement_model.dart';

// Basit user model, auth_service için gerekli
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final bool isAnonymous;
  final DateTime? lastSignIn;
  final Map<String, dynamic>? metadata;
  final List<String> subscribedTopics;
  final Map<String, DateTime> readAnnouncements;
  final String? fcmToken;
  // Bildirim alanları
  final Map<String, bool> readNotifications;  // read içindeki bildirim ID'leri
  final Map<String, bool> deletedNotifications; // delete içindeki bildirim ID'leri
  final int unreadCount; // okunmamış bildirim sayısı
  // Öğrenci bilgileri
  final String? studentNumber;
  final String? tck;
  final String? department;
  final String? faculty;
  final int? grade;
  final int? enrollmentYear;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.isAnonymous = false,
    this.lastSignIn,
    this.metadata,
    this.subscribedTopics = const ['anonim'],
    this.readAnnouncements = const {},
    this.fcmToken,
    this.readNotifications = const {},
    this.deletedNotifications = const {},
    this.unreadCount = 0,
    this.studentNumber,
    this.tck,
    this.department,
    this.faculty,
    this.grade,
    this.enrollmentYear,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email']?.toString() ?? '',
      displayName: map['displayName']?.toString(),
      isAnonymous: map['isAnonymous'] ?? false,
      lastSignIn: map['lastSignIn'] != null 
          ? DateTime.tryParse(map['lastSignIn'].toString())
          : null,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      subscribedTopics: map['subscribedTopics'] != null 
          ? List<String>.from(map['subscribedTopics'])
          : ['anonim'],
      readAnnouncements: map['readAnnouncements'] != null 
          ? Map<String, DateTime>.from((map['readAnnouncements'] as Map).map(
              (key, value) => MapEntry(key.toString(), DateTime.parse(value.toString()))))
          : {},
      fcmToken: map['fcmToken']?.toString(),
      // Bildirim alanları
      readNotifications: map['notifications']?['read'] != null 
          ? Map<String, bool>.from(map['notifications']['read'])
          : {},
      deletedNotifications: map['notifications']?['delete'] != null 
          ? Map<String, bool>.from(map['notifications']['delete'])
          : {},
      unreadCount: map['notifications']?['unread_count'] ?? 0,
      // Öğrenci bilgileri
      studentNumber: map['studentNumber']?.toString(),
      tck: map['tck']?.toString(),
      department: map['department']?.toString(),
      faculty: map['faculty']?.toString(),
      grade: map['grade'] != null ? int.tryParse(map['grade'].toString()) : null,
      enrollmentYear: map['enrollmentYear'] != null ? int.tryParse(map['enrollmentYear'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'isAnonymous': isAnonymous,
      'lastSignIn': lastSignIn?.toIso8601String(),
      'metadata': metadata,
      'subscribedTopics': subscribedTopics,
      'readAnnouncements': readAnnouncements.map((key, value) => MapEntry(key, value.toIso8601String())),
      'fcmToken': fcmToken,
      'notifications': {
        'read': readNotifications,
        'delete': deletedNotifications,
        'unread_count': unreadCount,
      },
      'studentNumber': studentNumber,
      'tck': tck,
      'department': department,
      'faculty': faculty,
      'grade': grade?.toString(),
      'enrollmentYear': enrollmentYear?.toString(),
    };
  }

  // Badge service için gerekli metod
  int getUnreadAnnouncementCount(List<AnnouncementModel> announcements) {
    return announcements.where((announcement) {
      // Eğer duyuru okunmamışsa unread sayısına dahil et
      return !readAnnouncements.containsKey(announcement.id);
    }).length;
  }

  // Additional methods for backwards compatibility
  bool isAnnouncementRead(String announcementId) {
    return readAnnouncements.containsKey(announcementId);
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isAnonymous,
    DateTime? lastSignIn,
    Map<String, dynamic>? metadata,
    List<String>? subscribedTopics,
    Map<String, DateTime>? readAnnouncements,
    String? userType,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? studentNumber,
    String? department,
    String? faculty,
    int? grade,
    int? enrollmentYear,
    int? age,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      lastSignIn: lastSignIn ?? this.lastSignIn,
      metadata: metadata ?? this.metadata,
      subscribedTopics: subscribedTopics ?? this.subscribedTopics,
      readAnnouncements: readAnnouncements ?? this.readAnnouncements,
    );
  }

  UserModel markAnnouncementAsRead(String announcementId) {
    final newReadAnnouncements = Map<String, DateTime>.from(readAnnouncements);
    newReadAnnouncements[announcementId] = DateTime.now();
    return copyWith(readAnnouncements: newReadAnnouncements);
  }

  // Bildirim helper metodları
  
  /// Bildirimi okundu olarak işaretle (local model güncelle)
  UserModel markNotificationAsRead(String notificationId) {
    final newReadNotifications = Map<String, bool>.from(readNotifications);
    newReadNotifications[notificationId] = true;
    
    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
      isAnonymous: isAnonymous,
      lastSignIn: lastSignIn,
      metadata: metadata,
      subscribedTopics: subscribedTopics,
      readAnnouncements: readAnnouncements,
      fcmToken: fcmToken,
      readNotifications: newReadNotifications,
      deletedNotifications: deletedNotifications,
      unreadCount: unreadCount,
    );
  }
  
  /// Bildirimi sil (local model güncelle)
  UserModel deleteNotification(String notificationId) {
    final newDeletedNotifications = Map<String, bool>.from(deletedNotifications);
    newDeletedNotifications[notificationId] = true;
    
    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
      isAnonymous: isAnonymous,
      lastSignIn: lastSignIn,
      metadata: metadata,
      subscribedTopics: subscribedTopics,
      readAnnouncements: readAnnouncements,
      fcmToken: fcmToken,
      readNotifications: readNotifications,
      deletedNotifications: newDeletedNotifications,
      unreadCount: unreadCount,
    );
  }
  
  /// Okunmamış sayısını güncelle (local model güncelle)
  UserModel updateUnreadCount(int newCount) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
      isAnonymous: isAnonymous,
      lastSignIn: lastSignIn,
      metadata: metadata,
      subscribedTopics: subscribedTopics,
      readAnnouncements: readAnnouncements,
      fcmToken: fcmToken,
      readNotifications: readNotifications,
      deletedNotifications: deletedNotifications,
      unreadCount: newCount,
    );
  }
  
  /// Bildirimin durumunu kontrol et
  bool isNotificationRead(String notificationId) {
    return readNotifications.containsKey(notificationId);
  }
  
  bool isNotificationDeleted(String notificationId) {
    return deletedNotifications.containsKey(notificationId);
  }

  int getUnreadNotificationCount() {
    // Yeni bildirim sistemindeki unread_count'u döndür
    return unreadCount;
  }

  // Getters for missing properties
  String get userType => isAnonymous ? 'anonymous' : 'student';
  String get userTypeString => isAnonymous ? 'Misafir' : 'Öğrenci';
  int get age => 20;
  bool get isStudent => !isAnonymous;
  Map<String, dynamic> get notificationStatus => {};
}
