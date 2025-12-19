import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/features/checkout/payment_selection.dart';
import 'checkout_provider.dart';
import 'shipping_form.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stepper(
        currentStep: state.step,
        onStepContinue: notifier.nextStep,
        onStepCancel: notifier.previousStep,
        steps: [
          Step(
            title: const Text('Shipping'),
            content: const ShippingForm(),
            isActive: state.step >= 0,
          ),
          Step(
            title: const Text('Review'),
            content: Text(
              'Name: ${state.name}\nPhone: ${state.phone}\nAddress: ${state.address}',
            ),
            isActive: state.step >= 1,
          ),
          Step(
            title: const Text('Payment'),
            content: const PaymentSelection(),
            isActive: state.step >= 2,
          ),
        ],
      ),
    );
  }
}
