import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../services/news_service.dart';
import '../../../../models/news_model.dart';

class NewsDetailScreen extends StatefulWidget {
  final String newsId;

  const NewsDetailScreen({
    super.key,
    required this.newsId,
  });

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final NewsService _newsService = NewsService();
  NewsModel? _newsData;
  String? _newsHtmlData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNewsDetail();
  }

  Future<void> _loadNewsDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Haber temel bilgilerini yükle
      final newsResult = await _newsService.getNewsById(widget.newsId);
      
      // Haber HTML içeriğini yükle
      final htmlResult = await _newsService.getNewsHtmlById(widget.newsId);

      setState(() {
        _newsData = newsResult;
        _newsHtmlData = htmlResult;
        _isLoading = false;
      });

      // Okuma sayısını artır
      if (_newsData != null) {
        await _newsService.incrementReadCount(widget.newsId);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Haber detayları yüklenirken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'URL açılamadı: $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link açılırken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(dynamic dateInput) {
    if (dateInput == null) return '';
    
    try {
      DateTime date;
      
      if (dateInput is DateTime) {
        date = dateInput;
      } else if (dateInput is String) {
        date = DateTime.parse(dateInput);
      } else {
        return '';
      }
      
      final months = [
        'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
        'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
      ];
      
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateInput.toString();
    }
  }

  Widget _buildCategoryChip(String category) {
    Color chipColor;
    switch (category.toLowerCase()) {
      case 'akademik':
        chipColor = Colors.blue;
        break;
      case 'araştırma':
        chipColor = Colors.green;
        break;
      case 'öğrenci':
        chipColor = Colors.orange;
        break;
      case 'öğrenci işleri':
        chipColor = Colors.purple;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        category,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Haber Detayı',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_newsData?.link != null && _newsData!.link!.startsWith('http'))
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => _launchUrl(_newsData!.link!),
              tooltip: 'Harici Bağlantıyı Aç',
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Paylaşım özelliği eklenecek
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Paylaşım özelliği yakında eklenecek'),
                ),
              );
            },
            tooltip: 'Paylaş',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Haber detayları yükleniyor...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Hata!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNewsDetail,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_newsData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Haber bulunamadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ana görsel
          if (_newsData!.resimUrl.isNotEmpty)
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_newsData!.resimUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // İçerik kısmı
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori ve tarih
                Row(
                  children: [
                    if (_newsData!.category != null)
                      _buildCategoryChip(_newsData!.category!),
                    const Spacer(),
                    Text(
                      _formatDate(_newsData!.createdAt),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Başlık
                Text(
                  _newsData!.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Yazar ve okuma sayısı
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _newsData!.author ?? 'Bilinmeyen Yazar',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.visibility,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_newsData!.readCount ?? 0} okunma',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Özet
                if (_newsData!.summary != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      _newsData!.summary!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF1E3A8A),
                        height: 1.4,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // HTML içerik veya normal içerik
                if (_newsHtmlData != null) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  Html(
                    data: _newsHtmlData!,
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        lineHeight: LineHeight(1.6),
                      ),
                      "h1": Style(
                        color: const Color(0xFF1E3A8A),
                        fontSize: FontSize(24),
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 16, bottom: 12),
                      ),
                      "h2": Style(
                        color: const Color(0xFF1E3A8A),
                        fontSize: FontSize(20),
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 16, bottom: 12),
                      ),
                      "h3": Style(
                        color: const Color(0xFF1E3A8A),
                        fontSize: FontSize(18),
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 16, bottom: 12),
                      ),
                      "p": Style(
                        margin: Margins.only(bottom: 12),
                        textAlign: TextAlign.justify,
                      ),
                      "ul": Style(
                        margin: Margins.only(left: 16, bottom: 12),
                      ),
                      "li": Style(
                        margin: Margins.only(bottom: 6),
                      ),
                      "blockquote": Style(
                        backgroundColor: Colors.grey.shade100,
                        padding: HtmlPaddings.all(16),
                        margin: Margins.symmetric(vertical: 16),
                        border: const Border(
                          left: BorderSide(color: Color(0xFF1E3A8A), width: 4),
                        ),
                      ),
                      "img": Style(
                        width: Width(double.infinity),
                        margin: Margins.symmetric(vertical: 16),
                      ),
                    },
                    onLinkTap: (url, attributes, element) {
                      if (url != null) {
                        _launchUrl(url);
                      }
                    },
                  ),
                ] else if (_newsData!.content != null) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    _newsData!.content!,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],

                const SizedBox(height: 24),

                // Harici bağlantı butonu
                if (_newsData!.link != null && _newsData!.link!.startsWith('http'))
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(_newsData!.link!),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Harici Bağlantıyı Aç'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Paylaşım butonu
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Paylaşım özelliği eklenecek
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Paylaşım özelliği yakında eklenecek'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Haberi Paylaş'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E3A8A),
                      side: const BorderSide(color: Color(0xFF1E3A8A)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
