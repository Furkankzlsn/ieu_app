import 'package:firebase_database/firebase_database.dart';

class MenuService {
  static final MenuService _instance = MenuService._internal();
  factory MenuService() => _instance;
  MenuService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Kategori bazlı menü verilerini getir
  Future<Map<String, dynamic>> getMenuByCategory(String category) async {
    try {
      final snapshot = await _database.child('menuler').child(category).get();
      
      if (!snapshot.exists) {
        print('⚠️ Menü verisi bulunamadı: $category');
        return {};
      }

      return Map<String, dynamic>.from(snapshot.value as Map);
    } catch (e) {
      print('❌ Menü getirme hatası: $e');
      return {};
    }
  }

  /// Üniversite menülerini getir
  Future<Map<String, dynamic>?> getUniversiteMenus() async {
    try {
      final snapshot = await _database.child('menuler/universite').get();
      
      if (!snapshot.exists) {
        print('⚠️ Üniversite menü verisi bulunamadı');
        return null;
      }

      return Map<String, dynamic>.from(snapshot.value as Map);
    } catch (e) {
      print('❌ Üniversite menü yükleme hatası: $e');
      return null;
    }
  }

  /// Akademik menülerini getir
  Future<Map<String, dynamic>?> getAkademikMenus() async {
    try {
      final snapshot = await _database.child('menuler/akademik').get();
      
      if (!snapshot.exists) {
        print('⚠️ Akademik menü verisi bulunamadı');
        return null;
      }

      return Map<String, dynamic>.from(snapshot.value as Map);
    } catch (e) {
      print('❌ Akademik menü yükleme hatası: $e');
      return null;
    }
  }

  /// Araştırma menülerini getir
  Future<Map<String, dynamic>?> getArastirmaMenus() async {
    try {
      final snapshot = await _database.child('menuler/arastirma').get();
      
      if (!snapshot.exists) {
        print('⚠️ Araştırma menü verisi bulunamadı');
        return null;
      }

      return Map<String, dynamic>.from(snapshot.value as Map);
    } catch (e) {
      print('❌ Araştırma menü yükleme hatası: $e');
      return null;
    }
  }

  /// Kampüs menülerini getir
  Future<Map<String, dynamic>?> getKampusMenus() async {
    try {
      final snapshot = await _database.child('menuler/kampus').get();
      
      if (!snapshot.exists) {
        print('⚠️ Kampüs menü verisi bulunamadı');
        return null;
      }

      return Map<String, dynamic>.from(snapshot.value as Map);
    } catch (e) {
      print('❌ Kampüs menü yükleme hatası: $e');
      return null;
    }
  }

  /// International menülerini getir
  Future<Map<String, dynamic>?> getInternationalMenus() async {
    try {
      final snapshot = await _database.child('menuler/international').get();
      
      if (!snapshot.exists) {
        print('⚠️ International menü verisi bulunamadı');
        return null;
      }

      return Map<String, dynamic>.from(snapshot.value as Map);
    } catch (e) {
      print('❌ International menü yükleme hatası: $e');
      return null;
    }
  }

  /// İletişim menülerini getir
  Future<Map<String, dynamic>?> getIletisimMenus() async {
    try {
      final snapshot = await _database.child('menuler/iletisim').get();
      
      if (!snapshot.exists) {
        print('⚠️ İletişim menü verisi bulunamadı');
        return null;
      }

      return Map<String, dynamic>.from(snapshot.value as Map);
    } catch (e) {
      print('❌ İletişim menü yükleme hatası: $e');
      return null;
    }
  }

  /// Menü içeriğini getir
  Future<Map<String, dynamic>?> getMenuContent(String category, String menuKey) async {
    try {
      final snapshot = await _database.child('menuler/$category/$menuKey').get();
      
      if (!snapshot.exists) {
        print('⚠️ Menü içeriği bulunamadı: $category/$menuKey');
        return null;
      }

      return Map<String, dynamic>.from(snapshot.value as Map);
    } catch (e) {
      print('❌ Menü içeriği yükleme hatası: $e');
      return null;
    }
  }

  /// Tüm menü kategorilerini getir
  Future<List<String>> getMenuCategories() async {
    try {
      final snapshot = await _database.child('menuler').get();
      
      if (!snapshot.exists) {
        print('⚠️ Menü kategorileri bulunamadı');
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.keys.map((key) => key.toString()).toList();
    } catch (e) {
      print('❌ Menü kategorileri getirme hatası: $e');
      return [];
    }
  }
}
