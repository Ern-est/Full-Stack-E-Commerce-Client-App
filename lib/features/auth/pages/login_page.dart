import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/features/auth/providers/auth_provider.dart';
import 'package:full_stack_e_commerce_app/features/auth/widgets/auth_form.dart';

class LoginPage extends ConsumerStatefulWidget {
  final VoidCallback onSwitch;
  const LoginPage({super.key, required this.onSwitch});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'Welcome Back',
      actionText: _loading ? 'Logging in...' : 'Login',
      onSubmit: () async {
        setState(() => _loading = true);
        try {
          final user = await ref
              .read(authServiceProvider)
              .login(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              );
          if (user != null) {
            // Auth state updates automatically
          }
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        } finally {
          setState(() => _loading = false);
        }
      },
      fields: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
      ],
      footer: TextButton(
        onPressed: widget.onSwitch,
        child: const Text("Don't have an account? Register"),
      ),
    );
  }
}
