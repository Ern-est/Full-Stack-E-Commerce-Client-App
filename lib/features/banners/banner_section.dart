import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  bool _autoScrollStarted = false; // 👈 important

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
      height: 200,
      child: bannersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (banners) {
          if (banners.isEmpty) {
            return const Center(child: Text('No banners found'));
          }

          // ✅ start auto-scroll ONCE after data loads
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
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (context, i) => _buildBannerCard(banners[i]),
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
              child: Image.network(
                banner.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
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
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    banner.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
            color: _currentIndex == i ? Colors.blueAccent : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
