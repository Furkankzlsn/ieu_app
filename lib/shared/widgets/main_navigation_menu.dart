import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';

class MainNavigationMenu extends StatelessWidget {
  const MainNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.marginM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF1E3A8A),
                  const Color(0xFF1E3A8A).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusM),
                topRight: Radius.circular(AppSizes.radiusM),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.dashboard,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Üniversite Menüsü',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'İEÜ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              children: [
                // Üniversite
                _buildMenuItem(
                  context,
                  'Üniversite',
                  Icons.account_balance,
                  const Color(0xFF1E3A8A),
                  'Kurumsal bilgiler ve yönetim',
                  () => _navigateToMenu(context, 'universite'),
                ),
                const SizedBox(height: 12),
                // Akademik
                _buildMenuItem(
                  context,
                  'Akademik',
                  Icons.school,
                  const Color(0xFF059669),
                  'Fakülteler ve programlar',
                  () => _navigateToMenu(context, 'akademik'),
                ),
                const SizedBox(height: 12),
                // Araştırma
                _buildMenuItem(
                  context,
                  'Araştırma',
                  Icons.science,
                  const Color(0xFFDC2626),
                  'Projeler ve yayınlar',
                  () => _navigateToMenu(context, 'arastirma'),
                ),
                const SizedBox(height: 12),
                // Kampüs
                _buildMenuItem(
                  context,
                  'Kampüs',
                  Icons.location_city,
                  const Color(0xFFEA580C),
                  'Kampüs yaşamı ve tesisler',
                  () => _navigateToMenu(context, 'kampus'),
                ),
                const SizedBox(height: 12),
                // International
                _buildMenuItem(
                  context,
                  'International',
                  Icons.public,
                  const Color(0xFF7C3AED),
                  'Uluslararası programlar',
                  () => _navigateToMenu(context, 'international'),
                ),
                const SizedBox(height: 12),
                // İletişim
                _buildMenuItem(
                  context,
                  'İletişim',
                  Icons.contact_mail,
                  const Color(0xFF0F766E),
                  'İletişim bilgileri',
                  () => _navigateToMenu(context, 'iletisim'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withValues(alpha: 0.5),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMenu(BuildContext context, String menuType) {
    Navigator.pushNamed(
      context,
      '/menu-category',
      arguments: {
        'category': menuType,
        'title': _getMenuTitle(menuType),
      },
    );
  }

  String _getMenuTitle(String menuType) {
    switch (menuType) {
      case 'universite':
        return 'Üniversite';
      case 'akademik':
        return 'Akademik';
      case 'arastirma':
        return 'Araştırma';
      case 'kampus':
        return 'Kampüs';
      case 'international':
        return 'International';
      case 'iletisim':
        return 'İletişim';
      default:
        return 'Menü';
    }
  }
}
