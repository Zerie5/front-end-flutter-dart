import 'package:flutter/material.dart';
import 'package:lul/utils/theme/widget_themes/text_field_theme.dart';
import 'package:lul/utils/constants/country_tele_list.dart';
import 'package:lul/utils/validators/validation.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:get/get.dart';

/// General Text Form Field for standard text input
class LulGeneralTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final bool obscureText;
  final int? maxLines;
  final String? hintText;
  final TextStyle? hintStyle;
  final Function(bool)? onFocusChange;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const LulGeneralTextFormField({
    super.key,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.maxLines = 1, // Default to 1
    this.hintText,
    this.hintStyle,
    this.onFocusChange,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: textInputAction,
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        obscureText: obscureText,
        maxLines: obscureText
            ? 1
            : maxLines, // Force maxLines to 1 if obscureText is true
        style: TTextFormFieldTheme.getTextStyle(context),
        decoration:
            TTextFormFieldTheme.getInputDecoration(context, hintText!).copyWith(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          hintStyle: hintStyle ??
              TTextFormFieldTheme.getInputDecoration(context, hintText!)
                  .hintStyle,
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
      ),
    );
  }
}

/// Text Form Field with Prefix Icon
class LulPrefixIconTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Icon prefixIcon;

  const LulPrefixIconTextFormField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TTextFormFieldTheme.getTextStyle(context),
      decoration:
          TTextFormFieldTheme.getInputDecoration(context, hintText).copyWith(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
        prefixIcon: prefixIcon,
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
    );
  }
}

/// Text Form Field with Suffix Icon
class LulSuffixIconTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Icon suffixIcon;

  const LulSuffixIconTextFormField({
    super.key,
    required this.hintText,
    required this.suffixIcon,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TTextFormFieldTheme.getTextStyle(context),
      decoration:
          TTextFormFieldTheme.getInputDecoration(context, hintText).copyWith(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
        suffixIcon: suffixIcon,
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
    );
  }
}

/// Password Text Form Field with Visibility Toggle
class LulPasswordTextFormField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const LulPasswordTextFormField({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
  });

  @override
  State<LulPasswordTextFormField> createState() =>
      _PasswordTextFormFieldState();
}

class _PasswordTextFormFieldState extends State<LulPasswordTextFormField> {
  bool _isObscured = true;

  void _toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _isObscured,
      style: TTextFormFieldTheme.getTextStyle(context),
      decoration:
          TTextFormFieldTheme.getInputDecoration(context, widget.hintText)
              .copyWith(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: _toggleVisibility,
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
    );
  }
}

class LulPhoneTextFormField extends StatefulWidget {
  const LulPhoneTextFormField({
    super.key,
    required this.phoneController,
    required this.languageController,
    this.initialValue,
    this.hintText,
    this.onRegionChanged,
    this.hintStyle,
    this.prefixIcon,
    this.focusNode,
  });

  final TextEditingController phoneController;
  final LanguageController languageController;
  final String? initialValue;
  final Function(String flag, IsoCode region)? onRegionChanged;
  final TextStyle? hintStyle;
  final String? hintText;
  final Widget? prefixIcon;
  final FocusNode? focusNode;

  @override
  State<LulPhoneTextFormField> createState() => _LulPhoneTextFormFieldState();
}

class _LulPhoneTextFormFieldState extends State<LulPhoneTextFormField> {
  final RxString _currentFlag = '🌐'.obs;
  final Rx<IsoCode> _currentRegionCode = IsoCode.US.obs;

  @override
  void initState() {
    super.initState();

    // Set initial value if provided
    if (widget.initialValue != null && widget.phoneController.text.isEmpty) {
      widget.phoneController.text = widget.initialValue!;
    }

    // Attach listener to phoneController
    widget.phoneController.addListener(() {
      final value = widget.phoneController.text;

      if (value.startsWith('+')) {
        try {
          final parsedPhone = PhoneNumber.parse(value);
          _currentRegionCode.value = parsedPhone.isoCode;
          _currentFlag.value =
              CountryCodeUtils.getFlagFromIsoCode(parsedPhone.isoCode);

          // Notify parent widget if needed
          if (widget.onRegionChanged != null) {
            widget.onRegionChanged!(
                _currentFlag.value, _currentRegionCode.value);
          }
        } catch (e) {
          // Handle invalid input gracefully
          _currentFlag.value = '🌐'; // Default to unknown flag
        }
      }
    });
  }

  @override
  void dispose() {
    widget.phoneController.removeListener(() {}); // Clean up listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return TextFormField(
        controller: widget.phoneController,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.phone,
        style: TTextFormFieldTheme.getTextStyle(
            context), // User-entered text style
        decoration: TTextFormFieldTheme.getInputDecoration(
          context,
          widget.hintText ?? '',
        ).copyWith(
          hintStyle: widget.hintStyle,
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 12.0, bottom: 12.0),
            child: Text(
              _currentFlag.value,
              style: const TextStyle(fontSize: 20),
            ),
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
        validator: (value) {
          return LValidator().validatePhoneNumber(
            value,
            regionCode: _currentRegionCode.value,
          );
        },
      );
    });
  }
}
