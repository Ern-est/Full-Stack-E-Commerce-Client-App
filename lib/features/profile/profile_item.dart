import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.pureWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      // ignore: deprecated_member_use
      shadowColor: AppTheme.goldDark.withOpacity(0.2),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.goldDark),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(color: AppTheme.primaryText),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.goldDark,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
