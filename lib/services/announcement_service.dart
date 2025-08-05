import 'package:firebase_database/firebase_database.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  static final AnnouncementService _instance = AnnouncementService._internal();
  factory AnnouncementService() => _instance;
  AnnouncementService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Tüm duyuruları getir
  Future<List<AnnouncementModel>> getAnnouncements({int? limit}) async {
    try {
      final snapshot = await _database.child('announcements').get();
      
      if (!snapshot.exists) {
        print('⚠️ Duyuru verisi bulunamadı');
        return [];
      }

      final data = snapshot.value as List<dynamic>;
      final List<AnnouncementModel> announcements = [];

      for (int i = 0; i < data.length; i++) {
        if (data[i] == null) continue; // Skip null entries
        
        try {
          final announcementData = Map<String, dynamic>.from(data[i] as Map);
          final announcement = AnnouncementModel.fromMap(announcementData);
          announcements.add(announcement);
        } catch (e) {
          print('❌ Duyuru parse hatası ($i): $e');
        }
      }

      // Tarihe göre sırala (en yeni önce)
      announcements.sort((a, b) => b.yayinTarihi.compareTo(a.yayinTarihi));
      
      // Limit uygula
      if (limit != null && announcements.length > limit) {
        return announcements.take(limit).toList();
      }
      
      print('✅ ${announcements.length} duyuru yüklendi');
      return announcements;
    } catch (e) {
      print('❌ Duyuru yükleme hatası: $e');
      return [];
    }
  }

  /// Duyuru stream (real-time)
  Stream<List<AnnouncementModel>> getAnnouncementsStream() {
    return _database.child('announcements').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <AnnouncementModel>[];

      final List<AnnouncementModel> announcements = [];
      
      if (data is List) {
        for (int i = 0; i < data.length; i++) {
          if (data[i] == null) continue;
          
          try {
            final announcementData = Map<String, dynamic>.from(data[i] as Map);
            final announcement = AnnouncementModel.fromMap(announcementData);
            announcements.add(announcement);
          } catch (e) {
            print('❌ Stream duyuru parse hatası ($i): $e');
          }
        }
      }

      // Tarihe göre sırala (en yeni önce)
      announcements.sort((a, b) => b.yayinTarihi.compareTo(a.yayinTarihi));

      return announcements;
    });
  }
}
