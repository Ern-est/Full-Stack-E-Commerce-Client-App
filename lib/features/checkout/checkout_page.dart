import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
import 'checkout_provider.dart';
import 'shipping_form.dart';
import 'payment_selection.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.ivory,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryText),
        titleTextStyle: AppTheme.luxuryTheme.textTheme.titleLarge,
      ),
      body: Stepper(
        currentStep: state.step,
        elevation: 0,
        type: StepperType.vertical,
        controlsBuilder: (context, details) {
          final isLast = state.step == 2;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: AppTheme.primaryText,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(isLast ? 'Place Order' : 'Next'),
                  ),
                ),
                if (state.step > 0) ...[
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: details.onStepCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryText,
                      foregroundColor: AppTheme.pureWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ],
              ],
            ),
          );
        },
        onStepContinue: () async {
          if (state.step < 2) {
            notifier.nextStep();
          } else {
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
            title: Text(
              'Shipping',
              style: AppTheme.luxuryTheme.textTheme.titleMedium,
            ),
            content: const ShippingForm(),
            isActive: state.step >= 0,
          ),
          Step(
            title: Text(
              'Review',
              style: AppTheme.luxuryTheme.textTheme.titleMedium,
            ),
            content: Card(
              color: AppTheme.pureWhite,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Name: ${state.name}\nPhone: ${state.phone}\nAddress: ${state.address}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            isActive: state.step >= 1,
          ),
          Step(
            title: Text(
              'Payment',
              style: AppTheme.luxuryTheme.textTheme.titleMedium,
            ),
            content: const PaymentSelection(),
            isActive: state.step >= 2,
          ),
        ],
      ),
    );
  }
}
