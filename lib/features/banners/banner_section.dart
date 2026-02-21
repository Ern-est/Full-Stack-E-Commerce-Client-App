import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
import 'package:full_stack_e_commerce_app/features/banners/banner.dart';
import 'package:full_stack_e_commerce_app/features/banners/banner_provider.dart';

class BannersSection extends ConsumerStatefulWidget {
  const BannersSection({super.key});

  @override
  ConsumerState<BannersSection> createState() => _BannersSectionState();
}

class _BannersSectionState extends ConsumerState<BannersSection> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  Timer? _autoScrollTimer;
  bool _autoScrollStarted = false;

  void _startAutoScroll(int bannerCount) {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_pageController.hasClients || bannerCount == 0) return;

      final nextPage = (_currentIndex + 1) % bannerCount;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _currentIndex = nextPage;
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(bannersProvider);

    return SizedBox(
      height: 220,
      child: bannersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Error: $err',
            style: TextStyle(color: AppTheme.primaryText),
          ),
        ),
        data: (banners) {
          if (banners.isEmpty) {
            return const Center(child: Text('No banners found'));
          }

          if (!_autoScrollStarted) {
            _autoScrollStarted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startAutoScroll(banners.length);
            });
          }

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: banners.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (_, i) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double scale = 1.0;
                        if (_pageController.position.haveDimensions) {
                          double page =
                              _pageController.page ??
                              _pageController.initialPage.toDouble();
                          scale = (1 - (page - i).abs() * 0.15).clamp(
                            0.85,
                            1.0,
                          );
                        }
                        return Transform.scale(
                          scale: scale,
                          child: _buildBannerCard(banners[i]),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              _buildIndicator(banners.length),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBannerCard(BannerModel banner) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () {
          if (banner.link != null && banner.link!.isNotEmpty) {
            // TODO: navigate or launch URL
          }
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Image.network(
                  banner.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (banner.title != null && banner.title!.isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    banner.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.ivory,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == i ? 12 : 8,
          height: _currentIndex == i ? 12 : 8,
          decoration: BoxDecoration(
            color: _currentIndex == i ? AppTheme.gold : AppTheme.divider,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
