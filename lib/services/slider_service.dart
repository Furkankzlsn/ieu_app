import 'package:firebase_database/firebase_database.dart';
import '../models/slider_model.dart';

class SliderService {
  static final SliderService _instance = SliderService._internal();
  factory SliderService() => _instance;
  SliderService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Aktif slider'ları getir
  Future<List<SliderModel>> getSliders() async {
    try {
      final snapshot = await _database.child('slider').get();
      
      if (!snapshot.exists) {
        print('⚠️ Slider verisi bulunamadı');
        return [];
      }

      final data = snapshot.value as List<dynamic>;
      final List<SliderModel> sliders = [];

      for (int i = 0; i < data.length; i++) {
        if (data[i] == null) continue; // Skip null entries
        
        try {
          final sliderData = Map<String, dynamic>.from(data[i] as Map);
          final slider = SliderModel.fromMap(sliderData);
          
          // Sadece aktif slider'ları ekle
          if (slider.aktif) {
            sliders.add(slider);
          }
        } catch (e) {
          print('❌ Slider parse hatası ($i): $e');
        }
      }

      // Sıraya göre sırala
      sliders.sort((a, b) => a.sira.compareTo(b.sira));
      
      print('✅ ${sliders.length} slider yüklendi');
      return sliders;
    } catch (e) {
      print('❌ Slider yükleme hatası: $e');
      return [];
    }
  }

  /// Slider HTML içeriğini getir
  Future<String?> getSliderHtmlById(String sliderId) async {
    try {
      final snapshot = await _database.child('slider_html').child(sliderId).get();
      
      if (!snapshot.exists) {
        print('⚠️ Slider HTML verisi bulunamadı: $sliderId');
        return null;
      }

      return snapshot.value as String?;
    } catch (e) {
      print('❌ Slider HTML getirme hatası: $e');
      return null;
    }
  }

  /// Slider stream (real-time)
  Stream<List<SliderModel>> getSlidersStream() {
    return _database.child('slider').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <SliderModel>[];

      final List<SliderModel> sliders = [];
      
      if (data is List) {
        for (int i = 0; i < data.length; i++) {
          if (data[i] == null) continue;
          
          try {
            final sliderData = Map<String, dynamic>.from(data[i] as Map);
            final slider = SliderModel.fromMap(sliderData);
            
            // Sadece aktif slider'ları ekle
            if (slider.aktif) {
              sliders.add(slider);
            }
          } catch (e) {
            print('❌ Stream slider parse hatası ($i): $e');
          }
        }
      }

      // Sıraya göre sırala
      sliders.sort((a, b) => a.sira.compareTo(b.sira));
      return sliders;
    });
  }

  /// ID'ye göre slider getir
  Future<SliderModel?> getSliderById(String sliderId) async {
    try {
      final snapshot = await _database.child('slider').get();
      
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.value as List<dynamic>;
      final index = int.tryParse(sliderId);
      
      if (index != null && index < data.length && data[index] != null) {
        final sliderData = Map<String, dynamic>.from(data[index] as Map);
        return SliderModel.fromMap(sliderData);
      }
      
      return null;
    } catch (e) {
      print('❌ Slider getirme hatası: $e');
      return null;
    }
  }

  /// Backwards compatibility methods
  Future<List<SliderModel>> getActiveSliders() => getSliders();
  Future<List<SliderModel>> getSlides() => getSliders();
}
