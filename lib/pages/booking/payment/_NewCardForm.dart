import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class NewCardForm extends StatefulWidget {
  final VoidCallback? onSaved;
  const NewCardForm({super.key, this.onSaved});

  @override
  State<NewCardForm> createState() => _NewCardFormState();
}

class _NewCardFormState extends State<NewCardForm> {
  final _nameController = TextEditingController();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _saveCard = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card_outlined,
                  color: AppColors.primaryPurple, size: 18),
              const SizedBox(width: 8),
              Text('DÉTAILS DE LA CARTE',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.subtext(context),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    fontSize: 11,
                  )),
            ],
          ),
          const SizedBox(height: 16),

          // Nom du titulaire
          _FieldLabel(label: 'Nom du titulaire'),
          const SizedBox(height: 6),
          _CardField(
            controller: _nameController,
            hint: 'John Doe',
            inputType: TextInputType.name,
          ),
          const SizedBox(height: 14),

          // Numéro de carte
          _FieldLabel(label: 'Numéro de carte'),
          const SizedBox(height: 6),
          _CardField(
            controller: _cardController,
            hint: '4242 4242 4242 4242',
            inputType: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
            ],
            maxLength: 19,
          ),
          const SizedBox(height: 14),

          // Expiration + CVV
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'Expiration'),
                    const SizedBox(height: 6),
                    _CardField(
                      controller: _expiryController,
                      hint: 'MM/YY',
                      inputType: TextInputType.number,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ExpiryFormatter(),
                      ],
                      maxLength: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'CVV'),
                    const SizedBox(height: 6),
                    _CardField(
                      controller: _cvvController,
                      hint: '123',
                      inputType: TextInputType.number,
                      obscure: true,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxLength: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Enregistrer la carte
          GestureDetector(
            onTap: () => setState(() => _saveCard = !_saveCard),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _saveCard
                          ? AppColors.primaryPurple
                          : AppColors.border(context),
                      width: 2,
                    ),
                    color: _saveCard
                        ? AppColors.primaryPurple
                        : Colors.transparent,
                  ),
                  child: _saveCard
                      ? const Icon(Icons.check_rounded,
                          size: 12, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Icon(Icons.save_outlined,
                    size: 16, color: AppColors.subtext(context)),
                const SizedBox(width: 6),
                 Expanded(
        child: Text(
          'Enregistrer cette carte pour la prochaine fois',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall(context),
        ),
      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: AppTextStyles.bodySmall(context)
            .copyWith(color: AppColors.subtext(context)));
  }
}

class _CardField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType inputType;
  final bool obscure;
  final List<TextInputFormatter>? formatters;
  final int? maxLength;

  const _CardField({
    required this.controller,
    required this.hint,
    this.inputType = TextInputType.text,
    this.obscure = false,
    this.formatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscure,
      maxLength: maxLength,
      inputFormatters: formatters,
      style: AppTextStyles.bodyMedium(context),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        hintStyle: AppTextStyles.bodyMedium(context)
            .copyWith(color: AppColors.subtext(context)),
        filled: true,
        fillColor: AppColors.bg(context),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
      ),
    );
  }
}

// ── Formatters ────────────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    final text = next.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final string = buffer.toString();
    return next.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    var text = next.text.replaceAll('/', '');
    if (text.length > 2) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    return next.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}