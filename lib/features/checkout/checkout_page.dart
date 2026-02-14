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
        onStepContinue: () async {
          if (state.step < 2) {
            notifier.nextStep();
          } else {
            // Final step (Payment step)
            if (state.paymentMethod == 'COD') {
              try {
                await notifier.placeOrder();

                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            }
          }
        },
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
