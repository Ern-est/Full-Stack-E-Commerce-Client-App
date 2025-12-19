import 'package:flutter/material.dart';
import 'address_item.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> addresses = [
      {'label': 'Home', 'address': '123 Main Street, Nairobi'},
      {'label': 'Work', 'address': '456 Office Park, Nairobi'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length + 1,
        itemBuilder: (_, i) {
          if (i == addresses.length) {
            // Add new address button
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Open add address form
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Address'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          }
          final address = addresses[i];
          return AddressItem(
            label: address['label']!,
            address: address['address']!,
            onEdit: () {
              // TODO: Edit address
            },
            onDelete: () {
              // TODO: Delete address
            },
          );
        },
      ),
    );
  }
}
