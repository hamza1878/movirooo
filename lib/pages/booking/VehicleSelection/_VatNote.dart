import 'package:flutter/material.dart';

class VatNote extends StatelessWidget {
  const VatNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          Icon(Icons.check, size: 16, color: Colors.black87),
          SizedBox(width: 6),
          Text(
            'All prices include VAT, fees and tolls',
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}