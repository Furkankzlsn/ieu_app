import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class IEUValueCards extends StatelessWidget {
  const IEUValueCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final values = [
      {
        'title': 'Küresel Kariyer',
        'description': 'Uluslararası standartlarda eğitim',
        'icon': Icons.public,
        'color': const Color(0xFF1976D2),
      },
      {
        'title': 'Bilime Katkı',
        'description': 'Araştırma ve geliştirme odaklı',
        'icon': Icons.science,
        'color': const Color(0xFF388E3C),
      },
      {
        'title': 'İnsana Değer',
        'description': 'Her birey değerlidir',
        'icon': Icons.favorite,
        'color': const Color(0xFFD32F2F),
      },
      {
        'title': 'Topluma Fayda',
        'description': 'Toplumsal sorumluluk',
        'icon': Icons.groups,
        'color': const Color(0xFFF57C00),
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İEU Değerleri',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: values.length,
            itemBuilder: (context, index) {
              final value = values[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  onTap: () {
                    // Handle tap
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (value['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            value['icon'] as IconData,
                            size: 32,
                            color: value['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          value['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value['description'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textColor.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
