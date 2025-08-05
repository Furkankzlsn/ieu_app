import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class IEUValuesModel {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String linkUrl;

  IEUValuesModel({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.linkUrl,
  });
}

class IEUValuesSection extends StatelessWidget {
  const IEUValuesSection({Key? key}) : super(key: key);

  static final List<IEUValuesModel> _values = [
    IEUValuesModel(
      title: 'KÜRESEL KARİYER',
      subtitle: 'Dünya çapında fırsatlar',
      description: 'İzmir Ekonomi Üniversitesi, dünya çapında bir üniversiteye dönüşürken aynı zamanda küresel çapta yetkinliğe sahip başarılı gençler yetiştirir.',
      icon: Icons.public,
      color: AppColors.primaryColor,
      linkUrl: '/global-career',
    ),
    IEUValuesModel(
      title: 'BİLİME KATKI',
      subtitle: 'Araştırma ve inovasyon',
      description: 'İzmir Ekonomi Üniversitesi, nitelikli bilgi ve yetkin teknolojiler üretir.',
      icon: Icons.science,
      color: AppColors.successColor,
      linkUrl: '/research',
    ),
    IEUValuesModel(
      title: 'İNSANA DEĞER',
      subtitle: 'İnsan odaklı eğitim',
      description: 'İzmir Ekonomi Üniversitesi, toplumsal fayda üretmeyi varlık nedeni olarak görür.',
      icon: Icons.favorite,
      color: AppColors.errorColor,
      linkUrl: '/human-values',
    ),
    IEUValuesModel(
      title: 'TOPLUMA FAYDA',
      subtitle: 'Sosyal sorumluluk',
      description: '22 yıllık güç ve deneyimini toplumsal çalışmalara aktarmak.',
      icon: Icons.people,
      color: AppColors.warningColor,
      linkUrl: '/social-responsibility',
    ),
  ];

  void _onValueTap(BuildContext context, IEUValuesModel value) {
    // Navigate to value detail page
    print('Navigate to: ${value.linkUrl}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppColors.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'IEU DEĞERLERİ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Values grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _values.length,
            itemBuilder: (context, index) {
              final value = _values[index];
              return _buildValueCard(context, value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard(BuildContext context, IEUValuesModel value) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onValueTap(context, value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                value.color.withOpacity(0.1),
                value.color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: value.color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: value.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    value.icon,
                    color: value.color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  value.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: value.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Subtitle
                Text(
                  value.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Description
                Expanded(
                  child: Text(
                    value.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textColor.withOpacity(0.7),
                      height: 1.3,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Action indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Daha Fazla',
                      style: TextStyle(
                        fontSize: 11,
                        color: value.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: value.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
