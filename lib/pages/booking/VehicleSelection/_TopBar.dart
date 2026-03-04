import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
       IconButton(
  icon: const Icon(Icons.arrow_back),
  onPressed: () {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  },
),
          const SizedBox(width: 3),
          const Text(
            "Vehicle Selection",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}