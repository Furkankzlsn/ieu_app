import 'package:flutter/material.dart';
import '../../../../models/news_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/news_service.dart';

class CompactNewsList extends StatefulWidget {
  const CompactNewsList({Key? key}) : super(key: key);

  @override
  State<CompactNewsList> createState() => _CompactNewsListState();
}

class _CompactNewsListState extends State<CompactNewsList> {
  final NewsService _newsService = NewsService();
  List<NewsModel> _news = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      final news = await _newsService.getNews();
      setState(() {
        _news = news.take(3).toList(); // Show only 3 news items
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Haberler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full news page
                },
                child: const Text(
                  'Tümünü Gör',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            Container(
              height: 200,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_news.isEmpty)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: const Center(
                child: Text(
                  'Henüz haber bulunmuyor',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            Column(
              children: _news.map((news) => _buildNewsCard(news)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(NewsModel news) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Navigate to news detail
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // News Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    news.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        child: const Icon(
                          Icons.article,
                          color: AppColors.primaryColor,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // News Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      news.summary,
                      style: TextStyle(
                        color: AppColors.textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            news.category,
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(news.publishDate),
                          style: TextStyle(
                            color: AppColors.textColor.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    } else {
      return '${difference.inMinutes} dakika önce';
    }
  }
}
