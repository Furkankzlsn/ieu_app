import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../services/slider_service.dart';
import '../../../../models/slider_model.dart';

class SliderDetailScreen extends StatefulWidget {
  final String sliderId;

  const SliderDetailScreen({
    super.key,
    required this.sliderId,
  });

  @override
  State<SliderDetailScreen> createState() => _SliderDetailScreenState();
}

class _SliderDetailScreenState extends State<SliderDetailScreen> {
  final SliderService _sliderService = SliderService();
  SliderModel? _sliderData;
  String? _sliderHtmlData;
  bool _isLoading = true;
  String? _errorMessage;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _loadSliderDetail();
  }

  Future<void> _loadSliderDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Slider temel bilgilerini yükle
      final sliderResult = await _sliderService.getSliderById(widget.sliderId);
      
      // Slider HTML içeriğini yükle
      final htmlResult = await _sliderService.getSliderHtmlById(widget.sliderId);

      setState(() {
        _sliderData = sliderResult;
        _sliderHtmlData = htmlResult;
        _isLoading = false;
      });

      // WebView için YouTube URL'sini kontrol et
      if (_sliderHtmlData != null && _sliderHtmlData!.contains('youtube.com')) {
        _initializeWebView();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Slider detayları yüklenirken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_sliderHtmlData!));
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
          _sliderData?.baslik ?? 'Slider Detayı',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_sliderData?.link != null && _sliderData!.link.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => _launchUrl(_sliderData!.link),
              tooltip: 'Harici Bağlantıyı Aç',
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
              'Slider detayları yükleniyor...',
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
              onPressed: _loadSliderDetail,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_sliderData == null) {
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
              'Slider bulunamadı',
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
          if (_sliderData!.imageUrl.isNotEmpty)
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_sliderData!.imageUrl),
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
                // Başlık
                Text(
                  _sliderData!.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 8),

                // Kısa açıklama
                if (_sliderData!.body.isNotEmpty)
                  Text(
                    _sliderData!.body,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                const SizedBox(height: 16),

                // HTML içerik veya WebView
                if (_sliderHtmlData != null) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  if (_sliderHtmlData!.contains('youtube.com'))
                    // YouTube WebView
                    Container(
                      height: 400,
                      child: _webViewController != null
                          ? WebViewWidget(controller: _webViewController!)
                          : const Center(child: CircularProgressIndicator()),
                    )
                  else
                    // HTML İçerik
                    Html(
                      data: _sliderHtmlData!,
                      style: {
                        "body": Style(
                          fontSize: FontSize(16),
                          lineHeight: LineHeight(1.5),
                        ),
                        "h1": Style(
                          color: const Color(0xFF1E3A8A),
                          fontSize: FontSize(24),
                          fontWeight: FontWeight.bold,
                        ),
                        "h2": Style(
                          color: const Color(0xFF1E3A8A),
                          fontSize: FontSize(20),
                          fontWeight: FontWeight.bold,
                        ),
                        "h3": Style(
                          color: const Color(0xFF1E3A8A),
                          fontSize: FontSize(18),
                          fontWeight: FontWeight.bold,
                        ),
                        "p": Style(
                          margin: Margins.only(bottom: 12),
                        ),
                        "ul": Style(
                          margin: Margins.only(left: 16, bottom: 12),
                        ),
                        "li": Style(
                          margin: Margins.only(bottom: 4),
                        ),
                      },
                      onLinkTap: (url, attributes, element) {
                        if (url != null) {
                          _launchUrl(url);
                        }
                      },
                    ),
                ],

                const SizedBox(height: 24),

                // Harici bağlantı butonu
                if (_sliderData!.linkUrl != null && 
                    _sliderData!.linkUrl!.startsWith('http'))
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(_sliderData!.linkUrl!),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
