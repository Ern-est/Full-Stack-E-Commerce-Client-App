import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
import 'checkout_provider.dart';

class ShippingForm extends ConsumerWidget {
  const ShippingForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(checkoutProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField('Full Name', notifier.nameCtrl),
        const SizedBox(height: 12),
        _buildTextField(
          'Phone',
          notifier.phoneCtrl,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildTextField('Address', notifier.addressCtrl, maxLines: 2),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.primaryText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.secondaryText),
        filled: true,
        fillColor: AppTheme.ivory,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
