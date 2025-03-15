import 'package:flutter/material.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/theme/widget_themes/text_field_theme.dart';

class LulDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final String? Function(T?)? validator;
  final TextStyle? hintStyle;
  final Widget? prefixIcon;

  const LulDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.validator,
    this.hintStyle,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      alignment: AlignmentDirectional.centerStart,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
        hintStyle: hintStyle ??
            TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontFamily: 'Roboto',
              fontSize: TSizes.fontSizeMd,
            ),
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
      dropdownColor: TColors.primaryDark,
      style: TTextFormFieldTheme.getTextStyle(context),
      items: items,
      onChanged: onChanged,
      icon: Icon(
        Icons.arrow_drop_down,
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
      ),
      iconSize: 24,
      menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
      validator: validator,
    );
  }
}
