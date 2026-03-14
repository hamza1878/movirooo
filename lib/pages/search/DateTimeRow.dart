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
  late TimeOfDay _pickedTime;

  @override
  void initState() {
    super.initState();
    _pickedDate = widget.initialDate ?? DateTime.now();
    _pickedTime = _defaultTimeForDate(_pickedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTimeChanged?.call(_pickedTime);
    });
  }

  TimeOfDay _defaultTimeForDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final base = isToday ? now.add(const Duration(hours: 2)) : now;
    final roundedMinute = ((base.minute / 15).ceil() * 15) % 60;
    final extraHour = (base.minute >= 45) ? 1 : 0;
    return TimeOfDay(
      hour: (base.hour + extraHour) % 24,
      minute: roundedMinute,
    );
  }

  String get _dateLabel => _formatDate(_pickedDate);

  String get _timeLabel {
    final h = _pickedTime.hour.toString().padLeft(2, '0');
    final m = _pickedTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  // ── Date — calendar only, no edit/pin icon ────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      initialEntryMode: DatePickerEntryMode.calendarOnly, // ← removes pencil
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryPurple,
            onPrimary: Colors.white,
            onSurface: AppColors.text(context),
          ),
          // Hide the "Select date" header text
          textTheme: Theme.of(context).textTheme.copyWith(
                headlineMedium: const TextStyle(
                  fontSize: 0,
                  color: Colors.transparent,
                ),
                labelSmall: const TextStyle(
                  fontSize: 0,
                  color: Colors.transparent,
                ),
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final newDefault = _defaultTimeForDate(picked);
      setState(() {
        _pickedDate = picked;
        _pickedTime = newDefault;
      });
      widget.onDateChanged?.call(picked);
      widget.onTimeChanged?.call(newDefault);
    }
  }

  // ── Time — drum-roll bottom sheet: 00–23 | 00/15/30/45 ───────────
  Future<void> _pickTime() async {
    final minuteSlots = [0, 15, 30, 45];
    int initMinuteIndex =
        minuteSlots.indexWhere((m) => m == _pickedTime.minute);
    if (initMinuteIndex < 0) initMinuteIndex = 0;

    int tempHour = _pickedTime.hour;
    int tempMinuteIndex = initMinuteIndex;

    final hourCtrl = FixedExtentScrollController(initialItem: tempHour);
    final minuteCtrl =
        FixedExtentScrollController(initialItem: initMinuteIndex);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setBS) {
            return SizedBox(
              height: 340,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            final picked = TimeOfDay(
                              hour: tempHour,
                              minute: minuteSlots[tempMinuteIndex],
                            );
                            setState(() => _pickedTime = picked);
                            widget.onTimeChanged?.call(picked);
                          },
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Container(
                            height: 48,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 40),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primaryPurple.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ListWheelScrollView.useDelegate(
                                controller: hourCtrl,
                                itemExtent: 48,
                                diameterRatio: 1.4,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (i) => tempHour = i,
                                childDelegate:
                                    ListWheelChildBuilderDelegate(
                                  childCount: 24,
                                  builder: (_, i) => Center(
                                    child: Text(
                                      i.toString().padLeft(2, '0'),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              ':',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: ListWheelScrollView.useDelegate(
                                controller: minuteCtrl,
                                itemExtent: 48,
                                diameterRatio: 1.4,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (i) =>
                                    tempMinuteIndex = i,
                                childDelegate:
                                    ListWheelChildBuilderDelegate(
                                  childCount: 4,
                                  builder: (_, i) => Center(
                                    child: Text(
                                      minuteSlots[i]
                                          .toString()
                                          .padLeft(2, '0'),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    hourCtrl.dispose();
    minuteCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PillChip(
            label: _dateLabel,
            showChevron: true,
            onTap: _pickDate,
          ),
        ),
        const SizedBox(width: 10),
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
  final IconData? icon;
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