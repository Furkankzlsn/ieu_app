class AnnouncementModel {
  final String id;
  final String baslik;
  final String link;
  final DateTime yayinTarihi;

  AnnouncementModel({
    required this.id,
    required this.baslik,
    required this.link,
    required this.yayinTarihi,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id']?.toString() ?? '',
      baslik: map['baslik']?.toString() ?? '',
      link: map['link']?.toString() ?? '',
      yayinTarihi: DateTime.tryParse(map['yayinTarihi']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baslik': baslik,
      'link': link,
      'yayinTarihi': yayinTarihi.toIso8601String(),
    };
  }

  // Backwards compatibility getters
  DateTime get olusturmaTarihi => yayinTarihi;
}
