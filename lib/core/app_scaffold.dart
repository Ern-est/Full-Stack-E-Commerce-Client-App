import 'package:flutter/material.dart';
import 'responsive.dart';
import '../widgets/side_nav.dart';
import '../widgets/bottom_nav.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onNavTap;

  const AppScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    if (Responsive.isDesktop(context)) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Row(
          children: [
            SideNav(currentIndex: currentIndex, onTap: onNavTap),
            Expanded(
              child: Container(color: backgroundColor, child: body),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(color: backgroundColor, child: body),
      bottomNavigationBar: Responsive.isMobile(context)
          ? BottomNav(currentIndex: currentIndex, onTap: onNavTap)
          : null,
      drawer: Responsive.isTablet(context)
          ? SideNav(currentIndex: currentIndex, onTap: onNavTap)
          : null,
    );
  }
}
