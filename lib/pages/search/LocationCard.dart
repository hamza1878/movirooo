import 'package:flutter/material.dart';
import 'package:moviroo/theme/app_colors.dart';
import 'package:moviroo/theme/app_text_styles.dart';

class LocationCard extends StatefulWidget {
  const LocationCard({super.key});

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  String location = 'Tunis Carthage';
  String destination = 'As You Like';

  bool editingLocation = false;
  bool editingDestination = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          _buildRow(
            title: "CURRENT LOCATION",
            value: location,
            isEditing: editingLocation,
            icon: Icons.circle,
            onTap: () => setState(() {
              editingLocation = true;
              editingDestination = false;
            }),
            onSubmit: (value) {
              setState(() {
                if (value.isNotEmpty) location = value;
                editingLocation = false;
              });
            },
          ),

          Divider(color: AppColors.border(context), height: 1),

          _buildRow(
            title: "DESTINATION",
            value: destination,
            isEditing: editingDestination,
            icon: Icons.place_outlined, // 📍 destination icon
            onTap: () => setState(() {
              editingDestination = true;
              editingLocation = false;
            }),
            onSubmit: (value) {
              setState(() {
                if (value.isNotEmpty) destination = value;
                editingDestination = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String title,
    required String value,
    required bool isEditing,
    required IconData icon,
    required VoidCallback onTap,
    required Function(String) onSubmit,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryPurple, width: 2),
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 16),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.sectionLabel(context).copyWith(
                      color: AppColors.subtext(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),

                  isEditing
                      ? TextField(
                          autofocus: true,
                          
        
                          decoration: const InputDecoration(
                            hintText: "Type location",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
      
                           
                          ),
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          onSubmitted: onSubmit,
                        )
                      : Text(
                          value,
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ],
              ),
            ),
          ),

          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: AppColors.primaryPurple,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}