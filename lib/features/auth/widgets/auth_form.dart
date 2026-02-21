import 'package:flutter/material.dart';
import 'package:full_stack_e_commerce_app/core/responsive.dart';

class AuthForm extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final String actionText;
  final VoidCallback onSubmit;
  final Widget footer;

  const AuthForm({
    super.key,
    required this.title,
    required this.fields,
    required this.actionText,
    required this.onSubmit,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Container(
          width: isDesktop ? 420 : double.infinity,
          padding: const EdgeInsets.all(24),
          margin: isDesktop ? null : const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.cardColor, // ✅ from AppTheme
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ...fields,
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(actionText),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              footer,
            ],
          ),
        ),
      ),
    );
  }
}
