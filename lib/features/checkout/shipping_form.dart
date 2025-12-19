import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'checkout_provider.dart';

class ShippingForm extends ConsumerWidget {
  const ShippingForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(checkoutProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: notifier.nameCtrl,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: notifier.phoneCtrl,
          decoration: const InputDecoration(labelText: 'Phone'),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: notifier.addressCtrl,
          decoration: const InputDecoration(labelText: 'Address'),
          maxLines: 2,
        ),
      ],
    );
  }
}
