import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class IeuValuesWidget extends StatelessWidget {
  const IeuValuesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'IEU DEĞERLER',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Values Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3, // 1.2'den 1.3'e artırdık
              children: [
                _buildValueCard(
                  'Küresel Kariyer',
                  'Uluslararası iş birliği ve global fırsatlar',
                  Icons.public,
                  AppColors.primaryColor,
                ),
                _buildValueCard(
                  'Bilime Katkı',
                  'Araştırma ve geliştirme projeleri',
                  Icons.science,
                  AppColors.successColor,
                ),
                _buildValueCard(
                  'İnsana Değer',
                  'Öğrenci odaklı eğitim anlayışı',
                  Icons.people,
                  AppColors.warningColor,
                ),
                _buildValueCard(
                  'Topluma Fayda',
                  'Sosyal sorumluluk projeleri',
                  Icons.volunteer_activism,
                  AppColors.infoColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12), // 16'dan 12'ye azalttık
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10), // 12'den 10'a azalttık
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 28, // 32'den 28'e azalttık
              color: color,
            ),
          ),
          const SizedBox(height: 8), // 12'den 8'e azalttık
          Text(
            title,
            style: TextStyle(
              fontSize: 13, // 14'den 13'e azalttık
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3), // 4'den 3'e azalttık
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10, // 11'den 10'a azalttık
              color: AppColors.textColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
