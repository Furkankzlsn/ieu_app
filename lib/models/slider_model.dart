class SliderModel {
  final String resimUrl;
  final String link;
  final String baslik;
  final bool aktif;
  final int sira;

  SliderModel({
    required this.resimUrl,
    required this.link,
    required this.baslik,
    required this.aktif,
    required this.sira,
  });

  factory SliderModel.fromMap(Map<String, dynamic> map) {
    return SliderModel(
      resimUrl: map['resimUrl']?.toString() ?? '',
      link: map['link']?.toString() ?? '',
      baslik: map['baslik']?.toString() ?? '',
      aktif: map['aktif'] ?? true,
      sira: map['sira']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'resimUrl': resimUrl,
      'link': link,
      'baslik': baslik,
      'aktif': aktif,
      'sira': sira,
    };
  }

  // Resim URL'inin geçerli olup olmadığını kontrol et
  bool get hasValidImage => resimUrl.isNotEmpty && resimUrl.startsWith('http');

  // Link'in external mi internal mi olduğunu kontrol et
  bool get isExternalLink => link.startsWith('http');

  // Compatibility getters for backwards compatibility
  String get title => baslik; // Başlık için uyumluluk
  String get description => ''; // Artık açıklama yok
  String get aciklama => ''; // Artık açıklama yok
  String get body => ''; // Artık içerik yok
  String get imageUrl => resimUrl;
  String get linkUrl => link;
  String get actionText => 'Devamını Oku';
  String get subtitle => ''; // Artık alt başlık yok
}
