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

    return Scaffold(
      body: Center(
        child: Container(
          width: isDesktop ? 420 : double.infinity,
          padding: const EdgeInsets.all(24),
          margin: isDesktop ? null : const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 24),
              ...fields,
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  child: Text(actionText),
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
