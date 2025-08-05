class NewsModel {
  final String id;
  final String baslik;
  final String ozet;
  final String kategori;
  final String link;
  final String resimUrl;
  final DateTime yayinTarihi;
  final DateTime olusturmaTarihi; // Oluşturma tarihi için alias
  final List<String> skalar; // Ek bilgiler
  final int okunmaSayisi; // Okunma sayısı
  final bool onemli; // Önemli haber mi

  NewsModel({
    required this.id,
    required this.baslik,
    required this.ozet,
    required this.kategori,
    required this.link,
    required this.resimUrl,
    required this.yayinTarihi,
    DateTime? olusturmaTarihi,
    this.skalar = const [],
    this.okunmaSayisi = 0,
    this.onemli = false,
  }) : olusturmaTarihi = olusturmaTarihi ?? yayinTarihi;

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    final yayinTarihi = DateTime.tryParse(map['yayinTarihi']?.toString() ?? '') ?? DateTime.now();
    return NewsModel(
      id: map['id']?.toString() ?? '',
      baslik: map['baslik']?.toString() ?? '',
      ozet: map['ozet']?.toString() ?? '',
      kategori: map['kategori']?.toString() ?? 'Genel',
      link: map['link']?.toString() ?? '',
      resimUrl: map['resimUrl']?.toString() ?? '',
      yayinTarihi: yayinTarihi,
      olusturmaTarihi: DateTime.tryParse(map['olusturmaTarihi']?.toString() ?? '') ?? yayinTarihi,
      skalar: map['skalar'] != null ? List<String>.from(map['skalar']) : [],
      okunmaSayisi: map['okunmaSayisi']?.toInt() ?? 0,
      onemli: map['onemli'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baslik': baslik,
      'ozet': ozet,
      'kategori': kategori,
      'link': link,
      'resimUrl': resimUrl,
      'yayinTarihi': yayinTarihi.toIso8601String(),
      'olusturmaTarihi': olusturmaTarihi.toIso8601String(),
      'skalar': skalar,
      'okunmaSayisi': okunmaSayisi,
      'onemli': onemli,
    };
  }

  // Resim URL'inin geçerli olup olmadığını kontrol et
  bool get hasValidImage => resimUrl.isNotEmpty && resimUrl.startsWith('http');

  // Compatibility getters for backwards compatibility
  String get title => baslik;
  String get summary => ozet;
  String get content => ozet; // İçerik artık ozet ile aynı
  String get category => kategori;
  String get imageUrl => resimUrl;
  String get author => 'İEU'; // Default author
  int get readCount => okunmaSayisi;
  DateTime get createdAt => olusturmaTarihi;
  DateTime get publishDate => yayinTarihi;

  // Helper method to format date
  String get formattedDate {
    return '${yayinTarihi.day}.${yayinTarihi.month}.${yayinTarihi.year}';
  }

  // Additional getters for backwards compatibility
  bool get isPinned => onemli;
}
