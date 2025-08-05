import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../models/news_model.dart';
import '../utils/webview_utils.dart';

class CompactNewsWidget extends StatelessWidget {
  final List<NewsModel> newsList;

  const CompactNewsWidget({
    Key? key,
    required this.newsList,
  }) : super(key: key);

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
              'HABERLER',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // News List
          if (newsList.isEmpty)
            Container(
              height: 150,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: const Center(
                child: Text(
                  'Haberler yükleniyor...',
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  final news = newsList[index];
                  return _buildNewsCard(context, news);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, NewsModel news) {
    return GestureDetector(
      onTap: () {
        if (news.link.isNotEmpty) {
          openWebView(context, news.link, title: news.baslik);
        }
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.borderRadius),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                child: news.resimUrl.isNotEmpty
                    ? Image.network(
                        news.resimUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: AppColors.textColor,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        child: const Icon(
                          Icons.article,
                          size: 40,
                          color: AppColors.primaryColor,
                        ),
                      ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and Important Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            news.kategori,
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (news.onemli) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'ÖNEMLİ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      news.baslik,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Summary
                    Expanded(
                      child: Text(
                        news.ozet,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textColor.withOpacity(0.7),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Date and Read Count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(news.yayinTarihi),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textColor.withOpacity(0.5),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 12,
                              color: AppColors.textColor.withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${news.okunmaSayisi}',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textColor.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }
}
