import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import './NewPassengerModal.dart';

// ── Public entry-point ────────────────────────────────────────────────────────
//
// Returns the selected index (int) or null if dismissed.
// The pill in LocationScreen reads _riders[selected]['name'] to update label.
//
// Usage:
//   final selected = await RiderSheet.show(
//     context,
//     riders: _riders,
//     initialSelected: _selectedRider,
//     onRidersChanged: (updated) => setState(() {
//       _riders..clear()..addAll(updated);
//     }),
//   );
//   if (selected != null) setState(() => _selectedRider = selected);
//
class RiderSheet {
  static Future<int?> show(
    BuildContext context, {
    required List<Map<String, String>> riders,
    int? initialSelected,
    required ValueChanged<List<Map<String, String>>> onRidersChanged,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (_) => _RiderSheetBody(
        initialSelected: initialSelected,
        riders: riders,
        onRidersChanged: onRidersChanged,
      ),
    );
  }
}

// ── Sheet body ────────────────────────────────────────────────────────────────
class _RiderSheetBody extends StatefulWidget {
  final int? initialSelected;
  final List<Map<String, String>> riders;
  final ValueChanged<List<Map<String, String>>> onRidersChanged;

  const _RiderSheetBody({
    this.initialSelected,
    required this.riders,
    required this.onRidersChanged,
  });

  @override
  State<_RiderSheetBody> createState() => _RiderSheetBodyState();
}

class _RiderSheetBodyState extends State<_RiderSheetBody> {
  int? _selected;
  late List<Map<String, String>> _riders;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
    _riders = widget.riders.map((r) => Map<String, String>.from(r)).toList();
  }

  // ── Open NewPassengerModal (add or edit) ──────────────────────
  void _openPassengerForm({int? editIndex}) async {
    final result = await NewPassengerModal.show(
      context,
      initial: editIndex != null ? _riders[editIndex] : null,
    );
    if (result != null) {
      setState(() {
        if (editIndex != null) {
          _riders[editIndex] = result;
        } else {
          _riders.add(result);
        }
      });
      widget.onRidersChanged(_riders);
    }
  }

  // ── Delete ───────────────────────────────────────────────────
  void _deleteRider(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove contact',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content:
            Text('Remove "${_riders[index]['name']}" from your contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Remove',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        if (_selected == index) _selected = null;
        if (_selected != null && _selected! > index) {
          _selected = _selected! - 1;
        }
        _riders.removeAt(index);
      });
      widget.onRidersChanged(_riders);
    }
  }

  // ── 3-dot popup menu ─────────────────────────────────────────
  void _showMenu(BuildContext btnCtx, int index) async {
    final RenderBox button =
        btnCtx.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(btnCtx)
        .overlay!
        .context
        .findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final choice = await showMenu<String>(
      context: btnCtx,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined,
                size: 16, color: AppColors.primaryPurple),
            const SizedBox(width: 10),
            const Text('Edit',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline_rounded,
                size: 16, color: Colors.red.shade400),
            const SizedBox(width: 10),
            Text('Delete',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red.shade400)),
          ]),
        ),
      ],
    );

    if (choice == 'edit') _openPassengerForm(editIndex: index);
    if (choice == 'delete') _deleteRider(index);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title — centred
          Text(
            "Who's riding?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(height: 8),

          // Rider tiles
          ..._riders.asMap().entries.map((e) => Column(
                children: [
                  _RiderTile(
                    name: e.value['name']!,
                    subtitle: e.value['subtitle']!,
                    selected: _selected == e.key,
                    onTap: () => setState(() => _selected = e.key),
                    onMenuTap: (ctx) => _showMenu(ctx, e.key),
                  ),
                  if (e.key < _riders.length - 1)
                    const Divider(height: 1, thickness: 0.5),
                ],
              )),

          const Divider(height: 1, thickness: 0.5),

          // Add new contact
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add_alt_1_outlined,
                  size: 18, color: AppColors.primaryPurple),
            ),
            title: const Text(
              'Add New Contact',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryPurple),
            ),
            onTap: () => _openPassengerForm(),
          ),

          const SizedBox(height: 4),

          // Confirm — pops with the selected index
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selected != null
                  ? () => Navigator.pop(context, _selected)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                disabledBackgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _selected != null
                      ? Colors.white
                      : Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rider tile ────────────────────────────────────────────────────────────────
class _RiderTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final void Function(BuildContext menuContext) onMenuTap;

  const _RiderTile({
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person_outline_rounded,
            size: 18, color: AppColors.primaryPurple),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.text(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: AppColors.subtext(context)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          selected
              ? const Icon(Icons.check_circle_rounded,
                  color: AppColors.primaryPurple, size: 21)
              : Icon(Icons.radio_button_unchecked_rounded,
                  color: Colors.grey.shade300, size: 21),
          const SizedBox(width: 4),
          Builder(
            builder: (btnCtx) => GestureDetector(
              onTap: () => onMenuTap(btnCtx),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.more_vert_rounded,
                    size: 20, color: AppColors.subtext(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}