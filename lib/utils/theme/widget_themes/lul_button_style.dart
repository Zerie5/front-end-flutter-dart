import 'package:flutter/material.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/sizes.dart';

class LulButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final bool showShadow;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isDisabled;

  const LulButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.height = 60,
    this.width = double.infinity,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w500,
    this.borderRadius = 12,
    this.isLoading = false,
    this.padding,
    this.showShadow = false,
    this.prefixIcon,
    this.suffixIcon,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: theme.elevatedButtonTheme.style?.copyWith(
          padding: WidgetStateProperty.all(
            padding ?? const EdgeInsets.symmetric(vertical: 16),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return TColors.grey.withOpacity(0.3);
            }
            return backgroundColor ?? TColors.buttonPrimary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return TColors.grey;
            }
            return foregroundColor ?? TColors.white;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius!),
            ),
          ),
          elevation: WidgetStateProperty.all(showShadow ? 4 : 0),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(TColors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    const SizedBox(width: TSizes.spaceBtwItems),
                  ],
                  Text(
                    text,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: isDisabled
                          ? TColors.grey
                          : (foregroundColor ?? TColors.white),
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: TSizes.spaceBtwItems),
                    suffixIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}

class LulOutlineButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final double? height;
  final double? width;
  final Color? borderColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;

  const LulOutlineButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.height = 60,
    this.width = double.infinity,
    this.borderColor,
    this.textColor,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w500,
    this.borderRadius = 12,
    this.isLoading = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      height: height,
      width: width,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: borderColor ?? TColors.primary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius!),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
                ),
              )
            : Text(
                text,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: textColor ?? TColors.secondary,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
              ),
      ),
    );
  }
}
