import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import 'api_service.dart';

enum UserType { anonymous, student }

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  UserModel? _currentUser;
  UserType _userType = UserType.anonymous;

  UserModel? get currentUser => _currentUser;
  UserType get userType => _userType;
  bool get isLoggedIn => _userType == UserType.student && _currentUser != null;
  bool get isAnonymous => _userType == UserType.anonymous;

  /// İlk uygulama açılışında kullanıcı başlat
  Future<void> initializeUser() async {
    try {
      print('🔐 Kullanıcı kimlik doğrulama başlatılıyor...');

      // Daha önceki kullanıcı durumunu kontrol et
      final prefs = await SharedPreferences.getInstance();
      final savedUserType = prefs.getString('user_type');
      final savedUserId = prefs.getString('user_id');
      final savedDeviceUserId = prefs.getString('device_user_id');

      print('🔍 Saved data - userType: $savedUserType, userId: $savedUserId');

      if (savedUserType == 'student' && savedUserId != null) {
        // Öğrenci olarak giriş yapmış
        print('🎓 Öğrenci kullanıcı verisi bulundu, yükleniyor...');
        await _loadStudentUser(savedUserId);
      } else {
        // Anonymous kullanıcı - cihaz ID ile oluştur/yükle
        print('👤 Anonymous kullanıcı oluşturuluyor...');
        await _createAnonymousUser();
      }

      // FCM token'ı güncelle
      await updateFcmToken();

      print(
        '✅ Kullanıcı başlatma tamamlandı - Type: $_userType, isLoggedIn: $isLoggedIn',
      );
    } catch (e) {
      print('❌ Kullanıcı başlatma hatası: $e');
      await _createAnonymousUser(); // Fallback
    }
  }

  /// Anonymous kullanıcı oluştur
  Future<void> _createAnonymousUser() async {
    try {
      // Cihaz ID'si ile unique kullanıcı ID oluştur
      final deviceId = await _getDeviceId();

      // Önce bu cihaz ID'si ile kullanıcı var mı kontrol et
      final prefs = await SharedPreferences.getInstance();
      String? savedDeviceUserId = prefs.getString('device_user_id');

      String userId;
      if (savedDeviceUserId != null && savedDeviceUserId.isNotEmpty) {
        // Daha önce oluşturulmuş cihaz kullanıcısı var
        userId = savedDeviceUserId;
        print('📱 Mevcut cihaz kullanıcısı bulundu: $userId');
      } else {
        // Yeni cihaz kullanıcısı oluştur
        userId = deviceId;
        await prefs.setString('device_user_id', userId);
        print('📱 Yeni cihaz kullanıcısı oluşturuldu: $userId');
      }

      // FCM token al
      String? fcmToken;
      try {
        fcmToken = await _messaging.getToken();
      } catch (e) {
        print('⚠️ FCM token alınamadı: $e');
      }

      // Mevcut kullanıcı verilerini veritabanından kontrol et
      Map<String, dynamic>? existingUserData;
      Map<String, bool> existingReadNotifications = {};
      Map<String, bool> existingDeletedNotifications = {};
      int existingUnreadCount = 0;

      try {
        final snapshot = await _usersRef.child(userId).get();
        if (snapshot.exists) {
          // Firebase'den gelen veriyi güvenli şekilde cast et
          final rawData = snapshot.value;
          if (rawData is Map) {
            existingUserData = Map<String, dynamic>.from(rawData);

            // Mevcut notification verilerini koru
            if (existingUserData!['notifications'] != null) {
              final notificationDataRaw = existingUserData['notifications'];
              if (notificationDataRaw is Map) {
                final notificationData = Map<String, dynamic>.from(
                  notificationDataRaw,
                );

                if (notificationData['read'] != null &&
                    notificationData['read'] is Map) {
                  existingReadNotifications = Map<String, bool>.from(
                    notificationData['read'],
                  );
                }

                if (notificationData['deleted'] != null &&
                    notificationData['deleted'] is Map) {
                  existingDeletedNotifications = Map<String, bool>.from(
                    notificationData['deleted'],
                  );
                }

                existingUnreadCount =
                    (notificationData['unread_count'] as int?) ?? 0;
              }
            }

            print(
              '📱 Mevcut kullanıcı verisi bulundu - Read: ${existingReadNotifications.length}, Deleted: ${existingDeletedNotifications.length}, Unread: $existingUnreadCount',
            );
          }
        }
      } catch (e) {
        print('⚠️ Mevcut kullanıcı verisi alınamadı: $e');
      }

      // Anonymous kullanıcı modeli oluştur (mevcut notification verilerini koru)
      _currentUser = UserModel(
        id: userId,
        email: '',
        displayName: 'Misafir Kullanıcı',
        subscribedTopics: ['anonim'],
        fcmToken: fcmToken,
        readNotifications: existingReadNotifications,
        deletedNotifications: existingDeletedNotifications,
        unreadCount: existingUnreadCount,
      );

      // Veritabanına kaydet veya güncelle
      try {
        if (existingUserData != null) {
          // Kullanıcı zaten var - sadece gerekli alanları güncelle
          final updates = <String, dynamic>{
            'displayName': 'Misafir Kullanıcı',
            'subscribedTopics': ['anonim'],
            'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
          };

          // FCM token varsa güncelle
          if (fcmToken != null) {
            updates['fcmToken'] = fcmToken;
          }

          await _usersRef.child(userId).update(updates);
          print('✅ Mevcut kullanıcı güncellendi: $userId');
        } else {
          // Yeni kullanıcı - tüm veriyi yaz
          await _usersRef.child(userId).set(_currentUser!.toMap());
          print('✅ Yeni kullanıcı veritabanına kaydedildi: $userId');
        }
      } catch (e) {
        print('⚠️ Veritabanına kaydetme başarısız: $e');
      }

      // Anonymous topic'e abone ol
      try {
        await _messaging.subscribeToTopic('anonim');
      } catch (e) {
        print('⚠️ Topic aboneliği başarısız: $e');
      }

      // Local storage'a kaydet
      await prefs.setString('user_type', 'anonymous');
      await prefs.setString('user_id', userId);

      _userType = UserType.anonymous;
      print('✅ Anonymous kullanıcı hazır: $userId');
    } catch (e) {
      print('❌ Anonymous kullanıcı oluşturma hatası: $e');
      // Fallback: Minimum anonymous user oluştur
      _currentUser = UserModel(
        id: 'fallback_anonymous',
        email: '',
        displayName: 'Misafir Kullanıcı',
        subscribedTopics: ['anonim'],
      );
      _userType = UserType.anonymous;
    }
  }

  /// Öğrenci girişi (API ile)
  Future<bool> loginAsStudent({
    required String studentNumber,
    required String password,
  }) async {
    try {
      print('🔐 Öğrenci girişi deneniyor...');

      // Şifre kontrolü (şimdilik basit)
      if (studentNumber.isEmpty || password.isEmpty) {
        throw Exception('Lütfen tüm alanları doldurunuz');
      }

      // API'den öğrenci kontrolü yap
      final ApiService apiService = ApiService.instance;
      final response = await apiService.loginControl(studentNumber);

      if (!response.success) {
        throw Exception(response.error ?? 'Öğrenci kontrolü başarısız');
      }

      if (!response.data!.isActive) {
        throw Exception('Öğrenci aktif öğrenci listesinde bulunamadı');
      }

      // Mevcut anonymous kullanıcıyı temizle
      if (_userType == UserType.anonymous) {
        await _messaging.unsubscribeFromTopic('anonim');
      }

      // API'den gelen verilerle öğrenci verisi oluştur
      final studentData = _generateStudentDataFromApi(
        studentNumber,
        response.data!.data!,
      );

      // Firebase Auth kullanmıyoruz, doğrudan user ID oluştur
      final userId =
          'student_${studentNumber}_${DateTime.now().millisecondsSinceEpoch}';
      final fcmToken = await _messaging.getToken();

      // Öğrenci kullanıcı modeli oluştur
      _currentUser = UserModel(
        id: userId,
        email: '${studentNumber}@ieu.edu.tr',
        displayName: studentData['displayName']!,
        subscribedTopics: ['ieu_stu'],
        fcmToken: fcmToken,
        studentNumber: studentData['studentNumber'],
        tck: studentData['tck'],
        department: studentData['department'],
        grade: int.tryParse(studentData['grade'] ?? '1'),
        enrollmentYear: int.tryParse(
          studentData['enrollmentYear'] ?? DateTime.now().year.toString(),
        ),
      );

      // Veritabanına kaydet
      try {
        await _usersRef.child(userId).set(_currentUser!.toMap());
        print('✅ Öğrenci veritabanına kaydedildi: $userId');
      } catch (e) {
        print('⚠️ Veritabanına öğrenci kaydetme başarısız: $e');
      }

      // İEU öğrenci topic'ine abone ol
      try {
        await _messaging.subscribeToTopic('ieu_stu');
      } catch (e) {
        print('⚠️ İEU öğrenci topic aboneliği başarısız: $e');
      }

      // Local storage'ı güncelle
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', 'student');
      await prefs.setString('user_id', userId);
      await prefs.setString(
        'student_number',
        studentNumber,
      ); // Öğrenci numarasını da kaydet

      _userType = UserType.student;
      print('✅ Öğrenci girişi başarılı: ${studentData['displayName']}');
      print(
        '🔍 Debug - Current user type: $_userType, isLoggedIn: $isLoggedIn',
      );
      return true;
    } catch (e) {
      print('❌ Öğrenci giriş hatası: $e');
      return false;
    }
  }

  /// Öğrenci bilgilerini yükle
  Future<void> _loadStudentUser(String userId) async {
    try {
      print('🔄 Öğrenci kullanıcı yükleniyor: $userId');

      final snapshot = await _usersRef.child(userId).get();
      if (snapshot.exists) {
        final rawData = snapshot.value;
        if (rawData is Map) {
          final userData = Map<String, dynamic>.from(rawData);
          _currentUser = UserModel.fromMap(userId, userData);
          _userType = _currentUser!.userType == 'student'
              ? UserType.student
              : UserType.anonymous;

          // Eski kullanıcılar için subscribedTopics yoksa ekle
          if (_currentUser!.subscribedTopics.isEmpty) {
            List<String> defaultTopics = _currentUser!.isStudent
                ? ['ieu_stu']
                : ['anonim'];
            _currentUser = _currentUser!.copyWith(
              subscribedTopics: defaultTopics,
            );

            // Veritabanını güncelle
            await _usersRef.child(userId).update({
              'subscribedTopics': defaultTopics,
              'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
            });

            print('✅ Eski kullanıcı için topics eklendi: $defaultTopics');
          } else {
            // Son giriş zamanını güncelle
            await _usersRef.child(userId).update({
              'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
            });
          }

          print('✅ Öğrenci kullanıcı yüklendi: ${_currentUser!.displayName}');
          print('🔍 User type: $_userType, isLoggedIn: $isLoggedIn');
          print('🔍 User topics: ${_currentUser!.subscribedTopics}');
        } else {
          print('❌ Kullanıcı verisi geçersiz format');
          // SharedPreferences'taki geçersiz veriyi temizle
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('user_type');
          await prefs.remove('user_id');
          await _createAnonymousUser();
        }
      } else {
        print('❌ Kullanıcı veritabanında bulunamadı');

        // Eğer saved data'da student olarak kaydedilmişse, kullanıcıyı yeniden oluştur
        final prefs = await SharedPreferences.getInstance();
        final savedUserType = prefs.getString('user_type');

        if (savedUserType == 'student') {
          print(
            '🔄 Student kullanıcı veritabanında bulunamadı, yeniden oluşturuluyor...',
          );

          // Student no'yu SharedPreferences'tan al
          final savedStudentNumber = prefs.getString('student_number');

          if (savedStudentNumber != null && savedStudentNumber.isNotEmpty) {
            print(
              '📚 Kaydedilmiş öğrenci numarası bulundu: $savedStudentNumber',
            );

            // Student verisini yeniden oluştur
            final fcmToken = await _messaging.getToken();

            _currentUser = UserModel(
              id: userId,
              email: '${savedStudentNumber}@ieu.edu.tr',
              displayName: 'Test Öğrenci ${savedStudentNumber.substring(4)}',
              subscribedTopics: ['ieu_stu'],
              fcmToken: fcmToken,
              studentNumber: savedStudentNumber,
              tck: 'test_tck_$savedStudentNumber',
              department: 'Test Bölüm',
              grade: 1,
              enrollmentYear: 2021,
            );

            // Veritabanına kaydet
            await _usersRef.child(userId).set(_currentUser!.toMap());

            _userType = UserType.student;

            // İEU öğrenci topic'ine abone ol
            try {
              await _messaging.subscribeToTopic('ieu_stu');
            } catch (e) {
              print('⚠️ İEU öğrenci topic aboneliği başarısız: $e');
            }

            print(
              '✅ Student kullanıcı yeniden oluşturuldu: ${_currentUser!.displayName}',
            );
            print('🔍 User type: $_userType, isLoggedIn: $isLoggedIn');
            return;
          }
        }

        // Student değilse veya studentNumber bulunamazsa, SharedPreferences'ı temizle
        await prefs.remove('user_type');
        await prefs.remove('user_id');
        await _createAnonymousUser();
      }
    } catch (e) {
      print('❌ Öğrenci kullanıcı yükleme hatası: $e');
      // Hata durumunda SharedPreferences'ı temizle ve anonymous kullanıcı oluştur
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_type');
        await prefs.remove('user_id');
      } catch (prefError) {
        print('❌ SharedPreferences temizleme hatası: $prefError');
      }
      await _createAnonymousUser();
    }
  }

  /// API'den gelen verilerle öğrenci verisi oluştur
  Map<String, String> _generateStudentDataFromApi(
    String studentNumber,
    StudentData apiData,
  ) {
    return {
      'email': '${studentNumber}@student.ieu.edu.tr',
      'password': 'ieu_student_2024', // Sabit şifre
      'displayName': 'İEU Öğrenci ($studentNumber)',
      'studentNumber': studentNumber,
      'tck': apiData.tck,
      'department': 'Bilinmiyor', // API'den gelmediği için varsayılan
      'grade': '1',
      'enrollmentYear': DateTime.now().year.toString(),
    };
  }

  /// Çıkış yap
  Future<void> logout() async {
    try {
      if (_userType == UserType.student) {
        await _messaging.unsubscribeFromTopic('ieu_stu');
      }

      await _auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_type');
      await prefs.remove('user_id');
      await prefs.remove('student_number'); // Öğrenci numarasını da temizle

      _currentUser = null;

      // Anonymous kullanıcı oluştur
      await _createAnonymousUser();

      print('✅ Çıkış yapıldı, anonymous kullanıcıya dönüldü');
      print(
        '🔍 Debug - After logout - user type: $_userType, isLoggedIn: $isLoggedIn',
      );
    } catch (e) {
      print('❌ Çıkış hatası: $e');
    }
  }

  /// Kullanıcı bilgilerini güncelle
  Future<void> updateUserInfo() async {
    if (_currentUser != null) {
      try {
        _currentUser = _currentUser!.copyWith(lastLoginAt: DateTime.now());
        await _usersRef.child(_currentUser!.id).update({
          'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
        });
      } catch (e) {
        print('❌ Kullanıcı bilgisi güncelleme hatası: $e');
      }
    }
  }

  /// Bildirim okundu olarak işaretle
  Future<void> markNotificationAsRead(String notificationId) async {
    if (_currentUser == null) return;

    try {
      _currentUser = _currentUser!.markNotificationAsRead(notificationId);
      await _usersRef.child(_currentUser!.id).update({
        'notificationStatus': _currentUser!.notificationStatus.map(
          (key, value) => MapEntry(key, value.toMap()),
        ),
      });
      print('✅ Bildirim okundu olarak işaretlendi: $notificationId');
    } catch (e) {
      print('❌ Bildirim okuma işaretleme hatası: $e');
    }
  }

  /// Bildirimi sil
  Future<void> deleteNotification(String notificationId) async {
    if (_currentUser == null) return;

    try {
      _currentUser = _currentUser!.deleteNotification(notificationId);
      await _usersRef.child(_currentUser!.id).update({
        'notificationStatus': _currentUser!.notificationStatus.map(
          (key, value) => MapEntry(key, value.toMap()),
        ),
      });
      print('✅ Bildirim silindi: $notificationId');
    } catch (e) {
      print('❌ Bildirim silme hatası: $e');
    }
  }

  /// Duyuru okundu olarak işaretle
  Future<void> markAnnouncementAsRead(String announcementId) async {
    if (_currentUser == null) return;

    try {
      _currentUser = _currentUser!.markAnnouncementAsRead(announcementId);
      await _usersRef.child(_currentUser!.id).update({
        'readAnnouncements': _currentUser!.readAnnouncements,
      });
      print('✅ Duyuru okundu olarak işaretlendi: $announcementId');
    } catch (e) {
      print('❌ Duyuru okuma işaretleme hatası: $e');
    }
  }

  /// FCM Token'ı güncelle
  Future<void> updateFcmToken() async {
    try {
      if (_currentUser == null) return;

      final newToken = await _messaging.getToken();
      if (newToken != null && newToken != _currentUser!.fcmToken) {
        // Token değiştiyse güncelle
        _currentUser = UserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          displayName: _currentUser!.displayName,
          isAnonymous: _currentUser!.isAnonymous,
          lastSignIn: _currentUser!.lastSignIn,
          metadata: _currentUser!.metadata,
          subscribedTopics: _currentUser!.subscribedTopics,
          readAnnouncements: _currentUser!.readAnnouncements,
          fcmToken: newToken,
          readNotifications: _currentUser!.readNotifications,
          deletedNotifications: _currentUser!.deletedNotifications,
          unreadCount: _currentUser!.unreadCount,
        );

        // Veritabanında güncelle
        await _usersRef.child(_currentUser!.id).update({'fcmToken': newToken});
        print('✅ FCM Token güncellendi: ${newToken.substring(0, 20)}...');
      }
    } catch (e) {
      print('⚠️ FCM Token güncellenemedi: $e');
    }
  }

  /// Cihaza özel unique ID al
  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // iOS için identifierForVendor kullan
        return 'ios_${iosInfo.identifierForVendor ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}'}';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Android için androidId kullan
        return 'android_${androidInfo.id}';
      } else {
        // Diğer platformlar için timestamp based ID
        return 'device_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      print('⚠️ Cihaz ID alınamadı, fallback ID oluşturuluyor: $e');
      return 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Kullanıcı verilerini yenile (güncel veriyi veritabanından çek)
  Future<void> refreshUserData() async {
    try {
      if (_currentUser == null) return;

      final snapshot = await _usersRef.child(_currentUser!.id).get();
      if (snapshot.exists) {
        final rawData = snapshot.value;
        if (rawData is Map) {
          final userData = Map<String, dynamic>.from(rawData);
          _currentUser = UserModel.fromMap(_currentUser!.id, userData);
          print('✅ Kullanıcı verileri yenilendi');
        }
      }
    } catch (e) {
      print('❌ Kullanıcı verilerini yenileme hatası: $e');
    }
  }
}
