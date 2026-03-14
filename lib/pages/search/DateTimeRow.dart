import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class DateTimeRow extends StatefulWidget {
  final DateTime? initialDate;
  final void Function(DateTime)? onDateChanged;
  final void Function(TimeOfDay)? onTimeChanged;

  const DateTimeRow({
    super.key,
    this.initialDate,
    this.onDateChanged,
    this.onTimeChanged,
  });

  @override
  State<DateTimeRow> createState() => _DateTimeRowState();
}

class _DateTimeRowState extends State<DateTimeRow> {
  late DateTime _pickedDate;
  TimeOfDay? _pickedTime;

  @override
  void initState() {
    super.initState();
    _pickedDate = widget.initialDate ?? DateTime(2026, 3, 14);
  }

  String get _dateLabel => _formatDate(_pickedDate);

  String get _timeLabel {
    // Show current time by default instead of "Now"
    final t = _pickedTime ?? TimeOfDay.now();
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, $monthName ${date.day}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.primaryPurple,
            onPrimary: Colors.white,
            surface: AppColors.surface(context),
            onSurface: AppColors.text(context),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _pickedDate = picked);
      widget.onDateChanged?.call(picked);
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickedTime ?? now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.primaryPurple,
            onPrimary: Colors.white,
            surface: AppColors.surface(context),
            onSurface: AppColors.text(context),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _pickedTime = picked);
      widget.onTimeChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Date chip — NO calendar icon, shows "Sat, Mar 14" by default
        Expanded(
          child: _PillChip(
            label: _dateLabel,
            showChevron: true,
            onTap: _pickDate,
          ),
        ),
        const SizedBox(width: 10),
        // Time chip — shows current time by default
        Expanded(
          child: _PillChip(
            icon: Icons.access_time_rounded,
            label: _timeLabel,
            showChevron: true,
            onTap: _pickTime,
          ),
        ),
      ],
    );
  }
}

class _PillChip extends StatelessWidget {
  final IconData? icon; // nullable — date chip has no icon
  final String label;
  final bool showChevron;
  final VoidCallback onTap;

  const _PillChip({
    this.icon,
    required this.label,
    required this.showChevron,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.primaryPurple),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showChevron) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.subtext(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}