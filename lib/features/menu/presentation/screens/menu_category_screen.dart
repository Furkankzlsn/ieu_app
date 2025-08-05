import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/utils/webview_utils.dart';
import '../../../../services/menu_service.dart';

class MenuCategoryScreen extends StatefulWidget {
  const MenuCategoryScreen({super.key});

  @override
  State<MenuCategoryScreen> createState() => _MenuCategoryScreenState();
}

class _MenuCategoryScreenState extends State<MenuCategoryScreen> {
  final MenuService _menuService = MenuService();
  List<MenuItemModel> _menuItems = [];
  bool _isLoading = true;
  String _category = '';
  String _title = '';

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

      final menuData = await _menuService.getMenuByCategory(_category);
      print('📊 Firebase\'den gelen veri (${menuData.length} öğe): $menuData');
      
      final List<MenuItemModel> items = [];

      // Firebase verisini MenuItemModel listesine dönüştür
      menuData.forEach((key, value) {
        print('🔍 İşleniyor - Key: $key, Value: $value, Type: ${value.runtimeType}');
        if (value is Map<String, dynamic>) {
          final item = MenuItemModel(
            id: key,
            baslik: value['baslik'] ?? 'Başlık Yok',
            link: value['link'] ?? '',
            sira: value['sira'] ?? 0,
            aciklama: value['aciklama'],
          );
          items.add(item);
          print('✅ Eklendi: ${item.baslik} (Sıra: ${item.sira})');
        } else if (value is Map) {
          // Map türünü Map<String, dynamic>'e dönüştür
          final valueMap = Map<String, dynamic>.from(value);
          final item = MenuItemModel(
            id: key,
            baslik: valueMap['baslik'] ?? 'Başlık Yok',
            link: valueMap['link'] ?? '',
            sira: valueMap['sira'] ?? 0,
            aciklama: valueMap['aciklama'],
          );
          items.add(item);
          print('✅ Eklendi (Map dönüştürme): ${item.baslik} (Sıra: ${item.sira})');
        } else {
          print('❌ Geçersiz veri tipi: $key -> ${value.runtimeType}');
        }
      });

      // Sıraya göre sırala
      items.sort((a, b) => a.sira.compareTo(b.sira));
      print('📋 Toplam ${items.length} menü öğesi yüklendi ve sıralandı');

      setState(() {
        _menuItems = items;
        _isLoading = false;
      });

    } catch (e) {
      print('❌ Menü yükleme hatası: $e');
      print('❌ Hata detayı: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Menü yükleme hatası: $e'),
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
        title: Text(_title),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildMenuContent(),
    );
  }

  Widget _buildMenuContent() {
    if (_menuItems.isEmpty) {
      return const Center(
        child: Text(
          'Menü öğeleri bulunamadı',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _getCategoryIcon(),
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  _title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCategoryDescription(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Menu Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _menuItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return _buildMenuItem(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuItemModel item) {
    return InkWell(
      onTap: () => _openMenuItem(item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.baslik,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  if (item.aciklama != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.aciklama!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textColor.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: AppColors.primaryColor.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _openMenuItem(MenuItemModel item) {
    openWebView(
      context,
      item.link,
      title: item.baslik,
    );
  }

  IconData _getCategoryIcon() {
    switch (_category) {
      case 'universite':
        return Icons.account_balance;
      case 'akademik':
        return Icons.school;
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

  String _getCategoryDescription() {
    switch (_category) {
      case 'universite':
        return 'Kurumsal bilgiler ve yönetim';
      case 'akademik':
        return 'Fakülteler, yüksekokullar ve programlar';
      case 'arastirma':
        return 'Araştırma merkezleri ve projeler';
      case 'kampus':
        return 'Kampüs yaşamı ve tesisler';
      case 'international':
        return 'Uluslararası programlar';
      case 'iletisim':
        return 'İletişim bilgileri';
      default:
        return 'Menü kategorisi';
    }
  }
}

// MenuItemModel sınıfı
class MenuItemModel {
  final String id;
  final String baslik;
  final String link;
  final int sira;
  final String? aciklama;

  MenuItemModel({
    required this.id,
    required this.baslik,
    required this.link,
    required this.sira,
    this.aciklama,
  });
}
