import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

const List<String> carClasses = [
  'All',
  'Economy',
  'Standard',
  'Business',
  'Premium',
  'Van',
];

class ClassFilterBar extends StatelessWidget {
  final String selectedClass;
  final ValueChanged<String> onClassSelected;

  const ClassFilterBar({
    super.key,
    required this.selectedClass,
    required this.onClassSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: carClasses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = carClasses[index];
          final isActive = label == selectedClass;

          return GestureDetector(
            onTap: () => onClassSelected(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryPurple
                    : AppColors.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.primaryPurple
                      : AppColors.border(context),
                  width: 1.5,
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.bodySmall(context).copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.text(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}