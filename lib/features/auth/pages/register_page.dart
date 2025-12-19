import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/features/auth/providers/auth_provider.dart';
import 'package:full_stack_e_commerce_app/features/auth/widgets/auth_form.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final VoidCallback onSwitch;
  const RegisterPage({super.key, required this.onSwitch});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'Create Account',
      actionText: _loading ? 'Registering...' : 'Register',
      onSubmit: () async {
        setState(() => _loading = true);
        try {
          final user = await ref
              .read(authServiceProvider)
              .register(
                email: _emailController.text.trim(),
                password: _passwordController.text,
                name: _nameController.text.trim(),
              );
          if (user != null) {
            // Riverpod auth state will automatically update
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
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        const SizedBox(height: 12),
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
        child: const Text('Already have an account? Login'),
      ),
    );
  }
}
