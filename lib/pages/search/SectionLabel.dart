import 'package:flutter/material.dart';
import 'package:moviroo/theme/app_text_styles.dart';


class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.sectionLabel(context));
  }
}