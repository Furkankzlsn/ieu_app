import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../services/menu_service.dart';

class MenuCategoryScreen extends StatefulWidget {
  const MenuCategoryScreen({super.key});

  @override
  State<MenuCategoryScreen> createState() => _MenuCategoryScreenState();
}

class _MenuCategoryScreenState extends State<MenuCategoryScreen> {
  final MenuService _menuService = MenuService();
  Map<String, dynamic>? _menuData;
  bool _isLoading = true;
  String _category = '';
  String _title = '';

  // HTML strip fonksiyonu
  String _stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').replaceAll('&nbsp;', ' ').trim();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _category = args['category'] ?? '';
    _title = args['title'] ?? '';
    _loadMenuData();
  }

  Future<void> _loadMenuData() async {
    try {
      print('🔄 $_category kategorisi için menü verileri yükleniyor...');
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic>? menuData;
      
      // Kategori bazında Firebase'den veri çek
      switch (_category) {
        case 'universite':
          menuData = await _menuService.getUniversiteMenus();
          break;
        case 'akademik':
          menuData = await _menuService.getAkademikMenus();
          break;
        case 'arastirma':
          menuData = await _menuService.getArastirmaMenus();
          break;
        case 'kampus':
          menuData = await _menuService.getKampusMenus();
          break;
        case 'international':
          menuData = await _menuService.getInternationalMenus();
          break;
        case 'iletisim':
          menuData = await _menuService.getIletisimMenus();
          break;
        default:
          // Fallback için placeholder veri
          menuData = await _getPlaceholderMenuData();
      }
      
      if (menuData != null) {
        print('📊 $_category kategorisinde ${menuData.length} menü öğesi bulundu');
        menuData.forEach((key, value) {
          if (value is Map && value.containsKey('baslik')) {
            print('   - $key: ${value['baslik']}');
          }
        });
      } else {
        print('❌ $_category kategorisi için veri bulunamadı');
      }
      
      setState(() {
        _menuData = menuData;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ $_category menü yükleme hatası: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menü yüklenemedi: $e')),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _getPlaceholderMenuData() async {
    // Geçici placeholder veri - Firebase'e eklenene kadar
    switch (_category) {
      case 'akademik':
        return {
          'lisans_programlari': {
            'baslik': 'Lisans Programları',
            'icerik': 'Lisans programları bilgileri yakında eklenecektir.',
          },
          'yuksek_lisans': {
            'baslik': 'Yüksek Lisans',
            'icerik': 'Yüksek lisans programları bilgileri yakında eklenecektir.',
          },
          'doktora': {
            'baslik': 'Doktora',
            'icerik': 'Doktora programları bilgileri yakında eklenecektir.',
          },
        };
      case 'arastirma':
        return {
          'arastirma_merkezleri': {
            'baslik': 'Araştırma Merkezleri',
            'icerik': 'Araştırma merkezleri bilgileri yakında eklenecektir.',
          },
          'projeler': {
            'baslik': 'Projeler',
            'icerik': 'Projeler bilgileri yakında eklenecektir.',
          },
        };
      case 'kampus':
        return {
          'kampus_yasami': {
            'baslik': 'Kampüs Yaşamı',
            'icerik': 'Kampüs yaşamı bilgileri yakında eklenecektir.',
          },
          'ogrenci_kulupleri': {
            'baslik': 'Öğrenci Kulüpleri',
            'icerik': 'Öğrenci kulüpleri bilgileri yakında eklenecektir.',
          },
        };
      case 'international':
        return {
          'degisim_programlari': {
            'baslik': 'Değişim Programları',
            'icerik': 'Değişim programları bilgileri yakında eklenecektir.',
          },
          'uluslararasi_ogrenciler': {
            'baslik': 'Uluslararası Öğrenciler',
            'icerik': 'Uluslararası öğrenci bilgileri yakında eklenecektir.',
          },
        };
      case 'iletisim':
        return {
          'iletisim_bilgileri': {
            'baslik': 'İletişim Bilgileri',
            'icerik': 'İletişim bilgileri yakında eklenecektir.',
          },
          'kampus_haritasi': {
            'baslik': 'Kampüs Haritası',
            'icerik': 'Kampüs haritası yakında eklenecektir.',
          },
        };
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMenuContent(),
    );
  }

  Widget _buildMenuContent() {
    if (_menuData == null || _menuData!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Bu kategori için henüz içerik eklenmemiş',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Geri Dön'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      children: [
        // Kategori başlığı
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          margin: const EdgeInsets.only(bottom: AppSizes.marginM),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(),
                color: const Color(0xFF1E3A8A),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),

        // Menu items
        ..._menuData!.entries.map((entry) => _buildMenuItem(
          entry.value['baslik'] ?? entry.key,
          entry.value['icerik'] ?? 'İçerik bulunamadı',
          entry.key,
        )).toList(),
      ],
    );
  }

  Widget _buildMenuItem(String title, String content, String key) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.marginM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showMenuDetail(title, content, key),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article,
                  color: const Color(0xFF1E3A8A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      () {
                        String strippedContent = _stripHtmlTags(content);
                        return strippedContent.length > 80 
                            ? '${strippedContent.substring(0, 80)}...'
                            : strippedContent;
                      }(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenuDetail(String title, String content, String key) {
    Navigator.pushNamed(
      context,
      '/menu-detail',
      arguments: {
        'category': _category,
        'menuId': key,
        'title': title,
        'content': content,
      },
    );
  }

  IconData _getCategoryIcon() {
    switch (_category) {
      case 'universite':
        return Icons.school;
      case 'akademik':
        return Icons.book;
      case 'arastirma':
        return Icons.science;
      case 'kampus':
        return Icons.location_city;
      case 'international':
        return Icons.public;
      case 'iletisim':
        return Icons.contact_mail;
      default:
        return Icons.menu;
    }
  }
}
