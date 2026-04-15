import 'package:flutter/material.dart';
import 'package:damas_dashboard/core/app_colors.dart';

class ActivityTile extends StatelessWidget {
  final int index;

  const ActivityTile({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: const Icon(Icons.payment, color: Colors.green),
      ),
      title: Text("Order #882$index"),
      subtitle: const Text("Completed via Stripe"),
      trailing: const Text("+\$240"),
    );
  }
}