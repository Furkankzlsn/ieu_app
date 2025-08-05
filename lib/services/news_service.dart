import 'package:firebase_database/firebase_database.dart';
import '../models/news_model.dart';

class NewsService {
  static final NewsService _instance = NewsService._internal();
  factory NewsService() => _instance;
  NewsService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Tüm haberleri getir
  Future<List<NewsModel>> getNews({int? limit}) async {
    try {
      final snapshot = await _database.child('news').get();
      
      if (!snapshot.exists) {
        print('⚠️ Haber verisi bulunamadı');
        return [];
      }

      final data = snapshot.value as List<dynamic>;
      final List<NewsModel> newsList = [];

      for (int i = 0; i < data.length; i++) {
        if (data[i] == null) continue; // Skip null entries
        
        try {
          final newsData = Map<String, dynamic>.from(data[i] as Map);
          final news = NewsModel.fromMap(newsData);
          newsList.add(news);
        } catch (e) {
          print('❌ Haber parse hatası ($i): $e');
        }
      }

      // Tarihe göre sırala (en yeni önce)
      newsList.sort((a, b) => b.yayinTarihi.compareTo(a.yayinTarihi));
      
      // Limit uygula
      if (limit != null && newsList.length > limit) {
        return newsList.take(limit).toList();
      }
      
      print('✅ ${newsList.length} haber yüklendi');
      return newsList;
    } catch (e) {
      print('❌ Haber yükleme hatası: $e');
      return [];
    }
  }

  /// Kategori bazlı haber getir
  Future<List<NewsModel>> getNewsByCategory(String kategori, {int? limit}) async {
    try {
      final allNews = await getNews();
      final filteredNews = allNews
          .where((news) => news.kategori.toLowerCase() == kategori.toLowerCase())
          .toList();
      
      if (limit != null && filteredNews.length > limit) {
        return filteredNews.take(limit).toList();
      }
      
      return filteredNews;
    } catch (e) {
      print('❌ Kategori bazlı haber getirme hatası: $e');
      return [];
    }
  }

  /// ID'ye göre haber getir
  Future<NewsModel?> getNewsById(String newsId) async {
    try {
      final snapshot = await _database.child('news').get();
      
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.value as List<dynamic>;
      
      for (int i = 0; i < data.length; i++) {
        if (data[i] == null) continue;
        
        final newsData = Map<String, dynamic>.from(data[i] as Map);
        if (newsData['id']?.toString() == newsId) {
          return NewsModel.fromMap(newsData);
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Haber getirme hatası: $e');
      return null;
    }
  }

  /// Haber stream (real-time)
  Stream<List<NewsModel>> getNewsStream() {
    return _database.child('news').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <NewsModel>[];

      final List<NewsModel> newsList = [];
      
      if (data is List) {
        for (int i = 0; i < data.length; i++) {
          if (data[i] == null) continue;
          
          try {
            final newsData = Map<String, dynamic>.from(data[i] as Map);
            final news = NewsModel.fromMap(newsData);
            newsList.add(news);
          } catch (e) {
            print('❌ Stream haber parse hatası ($i): $e');
          }
        }
      }

      // Tarihe göre sırala
      newsList.sort((a, b) => b.yayinTarihi.compareTo(a.yayinTarihi));
      return newsList;
    });
  }

  /// ID'ye göre haber HTML içeriğini getir
  Future<String?> getNewsHtmlById(String newsId) async {
    try {
      final snapshot = await _database.child('haber_html').child(newsId).get();
      
      if (!snapshot.exists) {
        print('⚠️ Haber HTML verisi bulunamadı: $newsId');
        return null;
      }

      return snapshot.value as String?;
    } catch (e) {
      print('❌ Haber HTML getirme hatası: $e');
      return null;
    }
  }

  /// Haber okuma sayısını artır
  Future<void> incrementReadCount(String newsId) async {
    try {
      final readCountRef = _database.child('news_read_count').child(newsId);
      await readCountRef.runTransaction((Object? post) {
        return Transaction.success((post as int? ?? 0) + 1);
      });
    } catch (e) {
      print('❌ Haber okuma sayısı artırma hatası: $e');
    }
  }
}
