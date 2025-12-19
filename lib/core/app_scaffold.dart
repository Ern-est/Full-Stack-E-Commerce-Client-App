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
    if (Responsive.isDesktop(context)) {
      return Scaffold(
        body: Row(
          children: [
            SideNav(currentIndex: currentIndex, onTap: onNavTap),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: Responsive.isMobile(context)
          ? BottomNav(currentIndex: currentIndex, onTap: onNavTap)
          : null,
      drawer: Responsive.isTablet(context)
          ? SideNav(currentIndex: currentIndex, onTap: onNavTap)
          : null,
    );
  }
}
