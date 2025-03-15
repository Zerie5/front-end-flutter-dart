import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lul/utils/constants/colors.dart';

class LulDateField extends StatelessWidget {
  final TextEditingController controller;
  final String? initialValue;
  final String hintText;
  final TextStyle? hintStyle;
  final String? Function(String?)? validator;
  final Function(DateTime) onDateSelected;
  final Widget? prefixIcon;

  const LulDateField({
    super.key,
    required this.controller,
    this.initialValue,
    required this.hintText,
    this.hintStyle,
    this.validator,
    required this.onDateSelected,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (initialValue != null && controller.text.isEmpty) {
      controller.text = initialValue!;
    }

    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: validator,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: TColors.dark,
          ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        prefixIcon: prefixIcon ?? const Icon(Icons.calendar_today),
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
            width: 2,
          ),
        ),
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: TColors.primary,
                  onPrimary: TColors.white,
                  surface: TColors.white,
                  onSurface: TColors.dark,
                ),
                dialogTheme:
                    const DialogThemeData(backgroundColor: TColors.white),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
          controller.text = formattedDate;
          onDateSelected.call(picked);
        }
      },
    );
  }
}
