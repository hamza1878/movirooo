import 'package:flutter/material.dart';
import 'package:moviroo/theme/app_colors.dart';
import 'package:moviroo/theme/app_text_styles.dart';

class DateTimeRow extends StatefulWidget {
  const DateTimeRow({super.key});

  @override
  State<DateTimeRow> createState() => _DateTimeRowState();
}

class _DateTimeRowState extends State<DateTimeRow> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DateTimeTile(
            icon: Icons.calendar_month_outlined,
            label: 'Date',
            value:
                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
            onTap: _pickDate,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DateTimeTile(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: selectedTime.format(context),
            onTap: _pickTime,
          ),
        ),
      ],
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryPurple, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.sectionLabel(context)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}