import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/slider_model.dart';
import '../utils/webview_utils.dart';

class HomeSliderWidget extends StatelessWidget {
  final List<SliderModel> sliders;

  const HomeSliderWidget({
    Key? key,
    required this.sliders,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sliders.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: const Center(
          child: Text(
            'Slider yükleniyor...',
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: CarouselSlider(
        options: CarouselOptions(
        	height: 250,
        	autoPlay: true,
        	autoPlayInterval: const Duration(seconds: 5),
        	enlargeCenterPage: true,
        	viewportFraction: 0.9,
        	enableInfiniteScroll: sliders.length > 1,
        ),
        items: sliders.map((slider) {            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    if (slider.link.isNotEmpty) {
                      openWebView(
                        context, 
                        slider.link, 
                        title: slider.baslik.isNotEmpty ? slider.baslik : 'İEU Slider',
                      );
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      child: slider.hasValidImage
                          ? Image.network(
                              slider.resimUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: AppColors.textColor,
                                  ),
                                );
                              },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryColor,
                                    AppColors.primaryColor.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                );
              },
            );
        }).toList(),
      ),
    );
  }
}
