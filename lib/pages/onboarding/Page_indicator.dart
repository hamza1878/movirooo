import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int current;
  const PageIndicator({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 28 : 20,
          height: 4,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF7C3AED)
                : const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}