import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../services/menu_service.dart';

class MenuDetailScreen extends StatefulWidget {
  final String? category;
  final String? menuId;

  const MenuDetailScreen({
    super.key,
    this.category,
    this.menuId,
  });

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  final MenuService _menuService = MenuService();
  Map<String, dynamic>? _menuData;
  bool _isLoading = true;
  String? _errorMessage;
  String _category = '';
  String _menuId = '';
  String _title = '';
  String _content = '';

  // Gösterilecek içeriği döndüren getter
  String get displayContent {
    if (_menuData != null && _menuData!['icerik'] != null) {
      return _menuData!['icerik'];
    }
    return _content;
  }
  
  String get displayTitle {
    if (_menuData != null && _menuData!['baslik'] != null) {
      return _menuData!['baslik'];
    }
    return _title;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Arguments'tan veri al
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (args != null) {
      _category = args['category'] ?? widget.category ?? '';
      _menuId = args['menuId'] ?? widget.menuId ?? '';
      _title = args['title'] ?? '';
      _content = args['content'] ?? '';
    } else {
      _category = widget.category ?? '';
      _menuId = widget.menuId ?? '';
    }
    
    if (_category.isNotEmpty && _menuId.isNotEmpty) {
      _loadMenuContent();
    } else if (_content.isNotEmpty) {
      // Direkt content varsa Firebase'den çekmeye gerek yok
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // didChangeDependencies'de yapılacak
  }

  Future<void> _loadMenuContent() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final menuData = await _menuService.getMenuContent(_category, _menuId);

      setState(() {
        _menuData = menuData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Menü içeriği yüklenirken hata oluştu: $e';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          displayTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_menuData?['link'] != null)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => _launchUrl(_menuData!['link']),
              tooltip: 'Web Sitesinde Aç',
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
              'İçerik yükleniyor...',
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
              onPressed: _loadMenuContent,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_menuData == null && displayContent.isEmpty) {
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
              'İçerik bulunamadı',
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
          // Başlık bölümü
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E3A8A),
                  const Color(0xFF1E3A8A).withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _menuData!['baslik'] ?? '',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                if (_menuData!['guncellenmeTarihi'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Son güncelleme: ${_formatDate(_menuData!['guncellenmeTarihi'])}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // İçerik bölümü
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HTML içerik
                if (displayContent.isNotEmpty)
                  Html(
                    data: displayContent,
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        lineHeight: LineHeight(1.6),
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                      "h1": Style(
                        color: const Color(0xFF1E3A8A),
                        fontSize: FontSize(24),
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 20, bottom: 16),
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
                        backgroundColor: Colors.blue.shade50,
                        padding: HtmlPaddings.all(16),
                        margin: Margins.symmetric(vertical: 16),
                        border: const Border(
                          left: BorderSide(color: Color(0xFF1E3A8A), width: 4),
                        ),
                        fontStyle: FontStyle.italic,
                      ),
                      "img": Style(
                        width: Width(double.infinity),
                        margin: Margins.symmetric(vertical: 16),
                      ),
                      ".rector-message, .chairman-message, .mission-vision": Style(
                        margin: Margins.zero,
                      ),
                      ".rector-photo, .chairman-photo": Style(
                        textAlign: TextAlign.center,
                        margin: Margins.only(bottom: 16),
                      ),
                      ".message-content": Style(
                        margin: Margins.zero,
                      ),
                      ".value-item": Style(
                        backgroundColor: Colors.grey.shade50,
                        padding: HtmlPaddings.all(12),
                        margin: Margins.only(bottom: 12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    },
                    onLinkTap: (url, attributes, element) {
                      if (url != null) {
                        _launchUrl(url);
                      }
                    },
                  ),

                const SizedBox(height: 24),

                // Web sitesi butonu
                if (_menuData!['link'] != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(_menuData!['link']),
                      icon: const Icon(Icons.language),
                      label: const Text('Web Sitesinde Aç'),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
        'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
      ];
      
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
