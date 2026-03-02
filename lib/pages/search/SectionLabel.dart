import 'package:flutter/material.dart';
import 'package:moviroo/theme/app_text_styles.dart';


// ignore: unused_element
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    // Reuses AppTextStyles.sectionLabel — same as Login's "EMAIL ADDRESS" labels
    return Text(text, style: AppTextStyles.sectionLabel(context));
  }
}